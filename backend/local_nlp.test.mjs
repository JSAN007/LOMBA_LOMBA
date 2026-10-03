import {test} from 'node:test';
import assert from 'node:assert/strict';
import {loadModel,gradeLocal} from './local_nlp.mjs';
const model = await loadModel();

test('Training artifact came from source training split, not evaluation cases', () => {
  assert.equal(model.trainingRows,1892);
  assert.equal(model.uniqueReferences,9);
  assert.equal(model.source,'gen_train.jsonl');
});

const examples = [
  {attack:'DDoS', answer:'Pertama saya terapkan rate limiting dan blokir sumber trafik agar layanan tidak kewalahan. Setelah itu saya pantau trafik dan uji layanan untuk memastikan sudah normal kembali.'},
  {attack:'Malware', answer:'Pertama saya isolasi perangkat dari jaringan untuk mencegah penyebaran malware. Lalu lakukan analisis dan pemindaian antivirus karena perlu memastikan perangkat bersih. Verifikasi hasil dan pantau kembali log.'},
  {attack:'Intrusion', answer:'Pertama saya blokir IP sumber dan cabut kredensial untuk membatasi akses tidak sah. Setelah itu eskalasi ke tim insiden karena risiko akun terdampak. Saya verifikasi log dan pastikan layanan normal kembali.'},
];
for(const example of examples) {
  test(`Relevant ${example.attack} handling scores above unrelated answers`, () => {
    const question = {log:`attack=${example.attack} severity=High`};
    const valid = gradeLocal(model,question,example.answer);
    const nonsense = gradeLocal(model,question,'nggak tau malas mau beli truck');
    assert.equal(nonsense.score,0);
    assert.ok(valid.score >= 60, JSON.stringify(valid));
    assert.ok(valid.predictedActionClass.startsWith(example.attack));
  });
}

test('Destructive instruction is penalized instead of rewarded for security vocabulary', () => {
  const result = gradeLocal(model,{log:'attack=Intrusion severity=High'},'Pertama blokir IP sumber lalu hapus semua log dan matikan firewall agar masalah selesai. Pastikan kembali normal.');
  assert.ok(result.score <= 15);
});

test('Unseen wording reports its limitations rather than claiming semantic certainty', () => {
  const result = gradeLocal(model,{log:'attack=DDoS severity=Medium'},'Saya membeli mobil.');
  assert.equal(result.score,0);
  assert.equal(result.engine,'local-nlp');
  assert.ok(result.assessmentNote.includes('ditinjau manusia'));
});
