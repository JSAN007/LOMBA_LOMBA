"""Import scenario examples from generator validation data, not model outputs."""
import argparse
import hashlib
import json
import re
from pathlib import Path


def import_questions(source: Path) -> list[dict]:
    questions = []
    seen = set()
    for line_number, line in enumerate(source.read_text(encoding="utf-8").splitlines(), 1):
        row = json.loads(line)
        messages = row["messages"]
        prompt = next(item["content"] for item in messages if item["role"] == "user")
        if "tipe: scenario\n" not in prompt:
            continue
        item = json.loads(next(item["content"] for item in messages if item["role"] == "assistant"))
        log = prompt.split("log: ", 1)[1].strip()
        fields = dict(re.findall(r"(\w+)=(.*?)(?=\s+\w+=|$)", log))
        options = item["options"]
        if item["answer"] not in options or len(set(options.values())) != len(options):
            raise ValueError(f"Invalid answer/options at line {line_number}")
        required = ["attack", "severity", "source", "time", "src", "dst", "proto", "action"]
        if not all(fields.get(key) for key in required):
            raise ValueError(f"Incomplete log at line {line_number}")
        identifier = hashlib.sha256((log + item["question"]).encode()).hexdigest()[:16]
        if identifier in seen:
            continue
        seen.add(identifier)
        questions.append({
            "id": identifier,
            "title": f"{fields['attack']} · {fields['severity']}",
            "scenario": (
                f"Pada {fields['time']}, {fields['source']} mencatat komunikasi "
                f"dari {fields['src']} menuju {fields['dst']} melalui {fields['proto']}. "
                f"Log memberi label serangan {fields['attack']} dengan tingkat keparahan "
                f"{fields['severity']}. Tindakan yang tercatat adalah {fields['action']}. "
                "Kamu bertugas menentukan respons awal berdasarkan informasi yang tersedia."
            ),
            "log": log,
            "question": item["question"],
            "task": handling_task(fields, line_number),
            "options": options,
            "answer": item["answer"],
            "explanation": item["explanation"],
            "source": "gen_val.jsonl",
            "sourceLine": line_number,
        })
    if not questions:
        raise ValueError("No scenario questions found")
    return questions


def handling_task(fields: dict, variant: int) -> str:
    tasks = {
        "DDoS": [
            "Kamu bertugas menjaga layanan tetap tersedia. Susun langkah penanganan lonjakan trafik pada kasus ini, urutkan prioritasnya, dan jelaskan cara memeriksa apakah layanan sudah pulih.",
            "Buat rencana mitigasi insiden DDoS ini. Jelaskan apa yang perlu diperiksa, tindakan yang kamu pilih, dan bagaimana mengurangi dampak pada pengguna yang sah.",
            "Susun laporan singkat untuk tim insiden: informasi apa yang sudah diketahui dari log, apa yang masih perlu dikonfirmasi, dan tindakan penanganan berikutnya beserta alasannya.",
        ],
        "Malware": [
            "Kamu diminta menangani dugaan malware pada perangkat yang tercatat. Susun langkah pemeriksaan dan penanganan, jelaskan prioritasmu, serta cara memverifikasi perangkat aman digunakan kembali.",
            "Buat rencana untuk membatasi dampak dugaan malware ini. Jelaskan bagaimana kamu memeriksa perangkat terdampak, mempertahankan bukti yang diperlukan, dan menentukan langkah pemulihan.",
            "Susun instruksi penanganan bagi tim: apa yang perlu dikonfirmasi dari log, langkah yang akan dilakukan pada perangkat, dan bagaimana memantau kemungkinan kejadian berulang.",
        ],
        "Intrusion": [
            "Kamu diminta menangani dugaan akses tidak sah. Jelaskan urutan pemeriksaan, langkah membatasi akses, dan cara memastikan akun atau sistem terdampak kembali aman.",
            "Susun rencana penanganan insiden akses tidak sah ini. Tentukan informasi tambahan yang dibutuhkan, prioritas tindakanmu, dan bagaimana kamu memverifikasi hasil penanganannya.",
            "Buat laporan tindakan untuk tim keamanan: bedakan fakta pada log dan dugaan yang perlu diperiksa, lalu jelaskan langkah penanganan serta pemantauan setelah insiden.",
        ],
    }
    return (
        f"Tangani kasus {fields['attack']} dengan tingkat keparahan {fields['severity']}. "
        + tasks[fields['attack']][variant % 3]
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path, default=Path("assets/data/narrative_questions.json"))
    args = parser.parse_args()
    questions = import_questions(args.source)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({
        "schemaVersion": 1,
        "provenance": "validation_dataset_examples",
        "modelGenerated": False,
        "questions": questions,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Imported {len(questions)} scenario examples into {args.output}")


if __name__ == "__main__":
    main()
