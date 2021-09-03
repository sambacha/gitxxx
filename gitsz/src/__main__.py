"""
file gitsz.__main__.py
"""
import sys
import subprocess
import shlex
from pathlib import Path
import requests

from .utils import trim_indent, call_multiline

CMD = {
    "init": "Initialize new git along with .gitignore",
    "gi": "Generate gitignore from files in the directory",
    "commit": "Commit to git with the following message",
    "cpush": "Commit current changes and push to remote",
    "push": "Push changes to remote",
    "pull": "Pull changes from remote",
}


def main():
    argv = sys.argv

    if len(argv) <= 1:
        cli_default()
    elif argv[1] == "init":
        cli_init()
    elif argv[1] in {"commit", "cpush"}:
        try:
            cli_commit(argv[2])
        except IndexError:
            cli_commit(input("Please input your commit message: "))
        if argv[1] == "cpush":
            cli_push()

    elif argv[1] == "gi":
        cli_gi()
    elif argv[1] == "push":
        cli_push()
    elif argv[1] in {"-h", "--help", "help"}:
        print(
            trim_indent(
                """
        Acceptable commands:
        gitsz init           {init}
        gitsz commit message {commit}
        gitsz cpush message  {cpush}
        gitsz gi             {gi}
        gitsz push           {push}
        gitsz pull           {pull}
        gitsz                Prompt for choices
        """.format(
                    **CMD
                )
            )
        )


def cli_default():
    choice = input(
        trim_indent(
            """
    What do you want to do?
    1. {init}
    2. {commit}
    3. {cpush}
    4. {gi}
    5. {push}
    6. {pull}
    Please select [1-6]: 
    """.format(
                **CMD
            )
        )
    )

    if choice == "1":
        cli_init()
    elif choice in {"2", "3"}:
        cli_commit(input("Please input your commit message: "))
        if choice == "3":
            cli_push()
    elif choice == "4":
        cli_gi()
    elif choice == "5":
        cli_push()
    elif choice == "6":
        cli_pull()


def cli_init():
    cli_gi(_commit=False)
    subprocess.call(["git", "init"])


def cli_commit(s: str):
    call_multiline(
        """
    git add .
    git commit -m {}
    """.format(
            shlex.quote(s)
        )
    )


def cli_gi(_commit=True):
    try:
        gitignore_rows = Path(".gitignore").read_text().split("\n")
    except FileNotFoundError:
        gitignore_rows = []
    _append_gitignore(
        src=Path(__file__)
        .parent.joinpath("gitignore/{}.gitignore".format("global"))
        .read_text()
        .split("\n"),
        dst=gitignore_rows,
    )

    matched = set()
    for spec, filetypes in {
        "py": ["py"],
        "jvm": ["java", "kt"],
        "dart": ["dart"],
        "node": ["js", "ts", "jsx", "tsx"],
    }.items():
        for filetype in filetypes:
            try:
                next(Path(".").glob("**/*.{}".format(filetype)))
                if spec not in matched:
                    try:
                        _append_gitignore(
                            src=Path(__file__)
                            .parent.joinpath("gitignore/{}.gitignore".format(spec))
                            .read_text()
                            .split("\n"),
                            dst=gitignore_rows,
                        )
                    except FileNotFoundError:
                        pass

                matched.add(spec)
                matched.add(filetype)
            except StopIteration:
                pass

    if len(matched) > 0:
        r = requests.get(
            "https://www.gitignore.io/api/{}".format(
                ",".join({"kt": "kotlin", "py": "python"}.get(k, k) for k in matched)
            )
        )
        _append_gitignore(src=r.text.split("\n"), dst=gitignore_rows)

    with open(".gitignore", "w") as f:
        f.write("\n".join(gitignore_rows) + "\n")

    if _commit:
        subprocess.call(
            [
                "sh",
                "-c",
                "git ls-files -i --exclude-from=.gitignore | xargs git rm --cached",
            ]
        )
        cli_commit(input("Please input your commit message."))


def cli_push():
    if not subprocess.check_output(["git", "config", "remote.origin.url"]):
        subprocess.call(
            [
                "git",
                "remote",
                "add",
                "origin",
                shlex.quote(input("Please input the Git origin: ")),
            ]
        )

    subprocess.call(["git", "push", "origin", "master"])


def cli_pull():
    subprocess.call(["git", "pull", "origin", "master"])


def _append_gitignore(src: list, dst: list):
    for row in src:
        if row not in dst:
            if not row.startswith("#"):
                dst.append(row)
