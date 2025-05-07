import hashlib
import logging
from collections import defaultdict
from pathlib import Path


def find_duplicates(paths: list, mode: str = "name") -> dict:
    """find_duplicates
    Find duplicate files in a directory based on their name or checksum.
    """
    if mode == "name":
        return find_duplicates_by_name(paths)
    elif mode == "checksum":
        return find_duplicates_by_checksum(paths)
    elif mode == "both":
        return find_duplicates_by_both(paths)
    else:
        raise ValueError("Invalid mode. Choose 'name', 'checksum', or 'both'.")


def find_duplicates_by_name(paths: list) -> dict[str, list[Path]]:
    """find_duplicates_by_name
    Find duplicate files in a directory based on their basename.
    """
    files = [p for path in paths for p in path.rglob("*") if p.is_file()]
    groups: dict[str, list[Path]] = defaultdict(list)
    for file in files:
        groups[file.name].append(file)
    return {k: file_list for k, file_list in groups.items() if len(file_list) > 1}


def find_duplicates_by_checksum(paths: list) -> dict:
    """find_duplicates_by_checksum
    Find duplicate files in a directory based on their checksum.
    """

    files = [p for path in paths for p in path.rglob("*") if p.is_file()]
    groups: dict[str, list[Path]] = defaultdict(list)
    for file in files:
        with open(file, "rb") as f:
            content = f.read()
            checksum = hashlib.md5(content).hexdigest()
            groups[checksum].append(file)
    return {k: file_list for k, file_list in groups.items() if len(file_list) > 1}


# TODO is this even usefull? same name but diffrent extension never have same checksum?
def find_duplicates_by_both(paths: list) -> dict:
    """find_duplicates_by_both
    Find duplicate files in a directory based on both name and checksum.
    """
    import hashlib

    files = [p for path in paths for p in path.rglob("*") if p.is_file()]
    groups: dict[str, list[Path]] = defaultdict(list)
    for file in files:
        with open(file, "rb") as f:
            content = f.read()
            checksum = hashlib.md5(content).hexdigest()
            groups[(file.stem, checksum)].append(file)
    return {k: v for k, v in groups.items() if len(v) > 1}


def delete_duplicates(
    duplicate_groups: dict[str, list[Path]], dry_run: bool = True, keep: int = 1
) -> list[Path]:
    deleted = []

    for group in duplicate_groups.values():
        to_delete = group[keep:] if keep >= 0 else group  # fallback if weird input

        for duplicate in to_delete:
            deleted.append(duplicate)
            if dry_run:
                logging.info(f"[dry-run] Would delete: {duplicate}")
            else:
                try:
                    duplicate.unlink()
                    logging.info(f"Deleted: {duplicate}")
                except Exception as e:
                    logging.warning(f"Failed to delete {duplicate}: {e}")

    return deleted
