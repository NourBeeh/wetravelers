#!/usr/bin/env python3
"""
WeTravellers Project Memory Updater.
Safe/additive: creates or updates memory files only.
Never deletes project files, never renames source files, never runs destructive commands.

Run from project root:
    python3 tools/update_project_memory.py
"""
from pathlib import Path
import json, subprocess, datetime

ROOT = Path(__file__).resolve().parents[1]
MEM = ROOT / "docs" / "project_memory"

def run(cmd):
    try:
        return subprocess.check_output(cmd, cwd=ROOT, text=True, stderr=subprocess.STDOUT).strip()
    except Exception as e:
        return f"[unavailable: {e}]"

def main():
    MEM.mkdir(parents=True, exist_ok=True)
    now = datetime.date.today().isoformat()
    files = [p for p in ROOT.rglob("*") if p.is_file() and ".git" not in p.parts]
    manifest_path = MEM / "PROJECT_MANIFEST.json"
    data = json.loads(manifest_path.read_text(encoding="utf-8")) if manifest_path.exists() else {}
    data["last_memory_update"] = now
    data["project_file_count"] = len(files)
    data["git_branch"] = run(["git", "branch", "--show-current"])
    data["git_status"] = run(["git", "status", "--short"])
    data["git_head"] = run(["git", "rev-parse", "--short", "HEAD"])
    (MEM / "PROJECT_MANIFEST.json").write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")

    (MEM / "CHANGELOG.md").open("a", encoding="utf-8").write(
        f"\n- Memory updater run: {now}; files={len(files)}; branch={data['git_branch']}; head={data['git_head']}\n"
    )
    print("WeTravellers memory updated safely.")

if __name__ == "__main__":
    main()
