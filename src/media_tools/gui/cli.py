from pathlib import Path

import typer

from media_tools.tools.deduper import delete_duplicates, find_duplicates
from media_tools.tools.raw_cleaner import find_jpeg_raw_pairs

app = typer.Typer(help="Media Tools CLI")


@app.command()
def dedup(
    path: Path = typer.Argument(..., help="Path to scan"),
    mode: str = typer.Argument(..., help="Deduplication mode"),
    dry_run: bool = typer.Option(
        False, "--dry-run", help="Simulate deletions without applying them"
    ),
):
    """Find and delete duplicate files."""
    dupes = find_duplicates([path], mode=mode)
    deleted = delete_duplicates(dupes, dry_run=dry_run)
    typer.echo(f"Duplicates found: {sum(len(v) - 1 for v in dupes.values())}")
    typer.echo(f"Files {'to be deleted' if dry_run else 'deleted'}: {len(deleted)}")
    for dup in dupes:
        typer.echo(f"delete {dup}: {dupes[dup]}")


@app.command("clean-raws")
def clean_raws(
    path: Path = typer.Argument(..., help="Path to scan"),
    dry_run: bool = typer.Option(
        False, "--dry-run", help="Simulate deletions without applying them"
    ),
):
    """Delete RAW files if JPEGs with the same name exist."""
    dupes = find_jpeg_raw_pairs([path])
    deleted = delete_duplicates(dupes, dry_run=dry_run, keep=0)
    typer.echo(f"RAW files {'to be deleted' if dry_run else 'deleted'}: {len(deleted)}")


def run():
    app()
