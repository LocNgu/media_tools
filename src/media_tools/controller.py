from pathlib import Path
from typing import Literal

from media_tools.tools.deduper import delete_duplicates, find_duplicates
from media_tools.tools.raw_cleaner import find_jpeg_raw_pairs


def run_dedup(
    paths: list[Path],
    mode: Literal["name", "checksum", "both"],
    dry_run: bool = True,
) -> dict[str, list[Path]]:
    dupes = find_duplicates(paths, mode=mode)
    deleted = delete_duplicates(dupes, dry_run=dry_run)
    return deleted


def run_raw_cleanup(
    paths: list[Path],
    dry_run: bool = True,
) -> int:
    dupes = find_jpeg_raw_pairs(paths)
    deleted = delete_duplicates(dupes, dry_run=dry_run, keep=0)
    return deleted
