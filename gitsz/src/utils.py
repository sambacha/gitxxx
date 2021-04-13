"""
file: gitsz.utils.py
"""
import re
import subprocess

def trim_indent(s: str) -> str:
    def process_match(match_obj):
        if match_obj is None:
            return 0
        else:
            return len(match_obj.group())

    rows = s.lstrip("\n").rstrip().split("\n")
    ws = min(process_match(re.match(r" +", r)) for r in rows)

    return "\n".join(r[ws:] for r in rows)

def call_multiline(s: str):
    for row in trim_indent(s).split("\n"):
        if row.strip():
            subprocess.call(["sh", "-c", row.strip()])
