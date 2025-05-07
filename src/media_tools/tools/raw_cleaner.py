from collections import defaultdict
from pathlib import Path

RAW_EXTS = [".raw", ".cr2", ".nef", ".arw", ".dng", ".raf"]
JPEG_EXTS = [".jpg", ".jpeg"]


def find_jpeg_raw_pairs(
    dirs: list[Path],
    raw_exts: list[str] = RAW_EXTS,
    jpeg_exts: list[str] = JPEG_EXTS,
    dry_run: bool = True,
) -> dict[str, list[Path]]:
    raw_map: dict[str, list[Path]] = defaultdict(list)
    jpeg_basenames = set()
    duplicates: dict[str, list[Path]] = defaultdict(list)

    for dir in dirs:
        for file in dir.rglob("*"):
            if not file.is_file():
                continue

            base = file.stem.lower()
            ext = file.suffix.lower()

            if ext in raw_exts:
                raw_map[base].append(file)
            elif ext in jpeg_exts:
                jpeg_basenames.add(base)
    for base, raw_files in raw_map.items():
        if base in jpeg_basenames:
            duplicates[base].extend(raw_files)

    return duplicates
