from collections import defaultdict
from pathlib import Path
from typing import Dict, List

RAW_EXTS = [".raw", ".cr2", ".nef", ".arw", ".dng", ".raf"]
JPEG_EXTS = [".jpg", ".jpeg"]


def find_jpeg_raw_pairs(
    dirs: List[Path],
    raw_exts: List[str] = RAW_EXTS,
    jpeg_exts: List[str] = JPEG_EXTS,
    dry_run: bool = True,
) -> Dict[str, List[Path]]:
    raw_map: Dict[str, List[Path]] = defaultdict(list)
    jpeg_basenames = set()
    duplicates: Dict[str, List[Path]] = defaultdict(list)

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
