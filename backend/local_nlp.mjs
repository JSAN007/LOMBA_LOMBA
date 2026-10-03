import {readFile} from 'node:fs/promises';

export function normalize(text) {
  return text.toLowerCase().normalize('NFKC')
    .replace(/\bddos\b/g, 'banjir trafik')
    .replace(/\brate limiting\b|\bpembatasan trafik\b|\bbatasi trafik\b/g, 'rate limiting')
    .replace(/\bmengisolasi\b|\bputuskan jaringan\b|\bputus koneksi\b/g, 'isolasi perangkat jaringan')
    .replace(/\bmonitor\b|\bmemonitor\b|\bpemantauan\b/g, 'pantau')
    .replace(/\bmencabut\b|\bnonaktifkan akun\b/g, 'cabut kredensial')
    .replace(/\bmemblokir\b|\bpemblokiran\b/g, 'blokir')
    .replace(/\bmalware\b|\bvirus\b/g, 'malware')
    .replace(/\bscan\b|\bmemindai\b/g, 'pemindaian')
    .replace(/\bmemeriksa\b|\bpengecekan\b/g, 'periksa')
    .replace(/[^a-z0-9\s]/g, ' ').replace(/\s+/g, ' ').trim();
}

export function features(text) {
  const clean = normalize(text);
  const counts = {};
  for (const token of clean.split(' ')) {
    if (token.length < 3) continue;
    counts[`w:${token}`] = (counts[`w:${token}`] || 0) + 1;
    for (let index = 0; index < token.length - 2; index++) {
      const key = `c:${token.slice(index, index + 3)}`;
      counts[key] = (counts[key] || 0) + 0.15;
    }
  }
  return counts;
}

function vector(text, idf) {
  const result = Object.fromEntries(Object.entries(features(text)).filter(([key]) => key in idf).map(([key, count]) => [key, Math.log1p(count) * idf[key]]));
  const length = Math.sqrt(Object.values(result).reduce((sum, value) => sum + value * value, 0));
  return Object.fromEntries(Object.entries(result).map(([key, value]) => [key, length ? value / length : 0]));
}

export function train(rows) {
  const unique = [...new Map(rows.map(row => [`${row.label}:${normalize(row.text)}`, row])).values()];
  const frequency = {};
  for (const row of unique) for (const key of Object.keys(features(row.text))) frequency[key] = (frequency[key] || 0) + 1;
  const idf = Object.fromEntries(Object.entries(frequency).map(([key, count]) => [key, Math.log((unique.length + 1) / (count + 1)) + 1]));
  const examples = unique.map(row => ({label:row.label, vector:vector(row.text, idf)}));
  return {version:'local-tfidf-rubric-v1', algorithm:'TF-IDF word/character retrieval + explicit rubric', trainingRows:rows.length, uniqueReferences:unique.length, idf, examples};
}

export async function loadModel() {
  return JSON.parse(await readFile(new URL('./models/local_nlp.json', import.meta.url), 'utf8'));
}

export function gradeLocal(model, question, answer) {
  const attack = question.log.match(/attack=(\w+)/)?.[1];
  const severity = question.log.match(/severity=(\w+)/)?.[1];
  if (!attack || !severity) throw new Error('invalid-question');
  const candidate = vector(answer, model.idf);
  const ranked = model.examples.map(example => ({label:example.label, similarity:Object.entries(candidate).reduce((sum,[key,value]) => sum + value * (example.vector[key] || 0), 0)})).sort((a,b) => b.similarity-a.similarity);
  const target = ranked.find(row => row.label === `${attack}:${severity}`);
  const attackMatch = ranked.filter(row => row.label.startsWith(`${attack}:`))[0];
  const normalized = normalize(answer);
  const relevant = (attackMatch?.similarity || 0) >= 0.18;
  const unsafe = /hapus (semua )?log|matikan (semua )?(firewall|antivirus)|abaikan (semua )?alert/.test(normalized);
  const unrelated = /nggak tahu|tidak tahu|malas|beli truck|beli truk|beri (saya )?nilai|nilai 100/.test(normalized) && normalized.length < 100;
  let accuracy = 0, priorities = 0, reasoning = 0, verification = 0;
  if (relevant && !unrelated) {
    accuracy = Math.min(25, Math.round((attackMatch.similarity / 0.6) * 20 + ((target?.similarity || 0) >= 0.2 ? 5 : 0)));
    priorities = Math.min(25, 5 + (/pertama|awalnya|langkah 1|1 /.test(normalized) ? 10 : 0) + (/kemudian|lalu|setelah|selanjutnya|2 /.test(normalized) ? 10 : 0));
    const reasons = normalized.match(/\b(karena|agar|untuk|sebab|risiko|mencegah)\b/g) || [];
    reasoning = Math.min(25, reasons.length * 10 + (answer.length > 100 ? 5 : 0));
    const checks = normalized.match(/\b(verifikasi|pastikan|pulih|uji|pantau|normal|kembali|periksa)\b/g) || [];
    verification = Math.min(25, checks.length * 8);
    if (unsafe) { accuracy = 0; priorities = Math.min(priorities, 5); reasoning = 0; verification = Math.min(verification, 5); }
  }
  const improvements = [];
  if (!relevant || unrelated) improvements.push('Jawab tugas penanganan insiden dengan tindakan yang relevan terhadap kasus.');
  if (unsafe) improvements.push('Tinjau ulang tindakan yang dapat menghilangkan bukti atau menonaktifkan proteksi.');
  if (accuracy < 20) improvements.push('Jelaskan tindakan konkret yang sesuai dengan jenis insiden dan tingkat keparahan.');
  if (priorities < 20) improvements.push('Urutkan langkah awal, tindakan berikutnya, dan pemulihan.');
  if (reasoning < 20) improvements.push('Tambahkan alasan dan risiko yang ingin dikurangi oleh setiap tindakan.');
  if (verification < 20) improvements.push('Jelaskan pemeriksaan hasil dan pemantauan setelah penanganan.');
  const score = accuracy + priorities + reasoning + verification;
  return {accuracy, priorities, reasoning, verification,
    feedback: !relevant || unrelated ? 'Jawaban belum menunjukkan langkah penanganan yang relevan dengan kasus.' : unsafe ? 'Ada tindakan berisiko yang perlu ditinjau ulang sebelum diterapkan.' : 'Penilai NLP menemukan tindakan yang berkaitan dengan kasus. Lengkapi aspek yang masih rendah.',
    improvements, engine:'local-nlp', assessmentNote:'Estimasi TF-IDF dan rubrik otomatis; jawaban kompleks, negasi, dan alternatif yang tidak dikenal perlu ditinjau manusia.',
    predictedActionClass:ranked[0]?.label ?? null,
    score, skillLevel:score < 20 ? 'Awam' : score < 40 ? 'Dasar' : score < 60 ? 'Menengah' : score < 80 ? 'Lanjutan' : 'Pro',
  };
}
