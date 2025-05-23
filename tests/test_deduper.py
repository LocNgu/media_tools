import hashlib
import tempfile
from pathlib import Path

from src.media_tools.tools.deduper import (
    delete_duplicates,
    find_duplicates,
)


def write_file(path: Path, content: bytes):
    path.write_bytes(content)


def hash_content(content: bytes):
    return hashlib.md5(content).hexdigest()


def test_find_duplicates_by_checksum():
    with tempfile.TemporaryDirectory() as tmpdir:
        p1 = Path(tmpdir) / "img1.jpg"
        p2 = Path(tmpdir) / "img2.jpg"
        p3 = Path(tmpdir) / "img3.jpg"

        write_file(p1, b"duplicate-content")
        write_file(p2, b"duplicate-content")
        write_file(p3, b"unique-content")

        result = find_duplicates([Path(tmpdir)], mode="checksum")
        checksum = hash_content(b"duplicate-content")
        assert checksum in result
        assert len(result[checksum]) == 2


def test_find_duplicates_by_both():
    with (
        tempfile.TemporaryDirectory() as tmpdir,
        tempfile.TemporaryDirectory() as tmpdir2,
    ):
        p1 = Path(tmpdir) / "file1.jpg"
        p2 = Path(tmpdir2) / "file1.JPG"
        p3 = Path(tmpdir) / "file3.jpg"

        write_file(p1, b"same")
        write_file(p2, b"same")
        write_file(p3, b"different")

        result = find_duplicates([Path(tmpdir), Path(tmpdir2)], mode="both")
        # should only return true duplicates — same name and same content
        assert len(result) == 1


def test_find_duplicates_same_file_diffrent_dirs():
    with (
        tempfile.TemporaryDirectory() as tmpdir1,
        tempfile.TemporaryDirectory() as tmpdir2,
    ):
        p1 = Path(tmpdir1) / "file1.jpg"
        p2 = Path(tmpdir2) / "file1.jpg"

        write_file(p1, b"same")
        write_file(p2, b"same")

        result = find_duplicates([Path(tmpdir1), Path(tmpdir2)], mode="both")
        # should only return true duplicates — same name and same content
        assert len(result) == 1


def test_delete_duplicates():
    with (
        tempfile.TemporaryDirectory() as tmpdir1,
        tempfile.TemporaryDirectory() as tmpdir2,
    ):
        p1 = Path(tmpdir1) / "file1.jpg"
        p2 = Path(tmpdir2) / "file1.jpg"

        write_file(p1, b"same")
        write_file(p2, b"same")

        duplicates = find_duplicates([Path(tmpdir1), Path(tmpdir2)], mode="name")
        deleted = delete_duplicates(duplicates)
        assert p2 in deleted


def test_delete_duplicates_real():
    with tempfile.TemporaryDirectory() as tmpdir:
        p1 = Path(tmpdir) / "img1.jpg"
        p2 = Path(tmpdir) / "img1_copy.jpg"
        p1.write_bytes(b"same")
        p2.write_bytes(b"same")

        dupes = find_duplicates([Path(tmpdir)], mode="checksum")
        to_delete = delete_duplicates(dupes, dry_run=False)

        # One file should be gone
        existing_files = list(Path(tmpdir).glob("*.jpg"))
        assert len(existing_files) == 1
        assert p1.exists() or p2.exists()
        assert len(to_delete) == 1


def test_delete_duplicates_dry_run():
    with tempfile.TemporaryDirectory() as tmpdir:
        p1 = Path(tmpdir) / "img1.jpg"
        p2 = Path(tmpdir) / "img1_copy.jpg"
        p1.write_bytes(b"same")
        p2.write_bytes(b"same")

        dupes = find_duplicates([Path(tmpdir)], mode="checksum")
        to_delete = delete_duplicates(dupes, dry_run=True)

        # Nothing should be deleted in dry-run
        assert p1.exists()
        assert p2.exists()
        assert p1 in to_delete or p2 in to_delete
        assert len(to_delete) == 1
