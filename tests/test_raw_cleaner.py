import tempfile
from pathlib import Path

from media_tools.tools.deduper import delete_duplicates
from media_tools.tools.raw_cleaner import find_jpeg_raw_pairs


def test_find_raw_jpg_duplicates():
    with (
        tempfile.TemporaryDirectory() as tmpdir1,
        tempfile.TemporaryDirectory() as tmpdir2,
    ):
        p1 = Path(tmpdir1) / "img1.jpg"  # noqa: F841
        p2 = Path(tmpdir1) / "img1.raw"
        p3 = Path(tmpdir2) / "img1.arw"
        p4 = Path(tmpdir1) / "img2.jpg"  # noqa: F841

        p1.write_bytes(b"same")
        p2.write_bytes(b"same")
        p3.write_bytes(b"same")
        p4.write_bytes(b"different")

        result = find_jpeg_raw_pairs([Path(tmpdir1), Path(tmpdir2)])
        assert "img1" in result
        assert p2 in result["img1"]
        assert len(result["img1"]) == 2
        assert p2 in result["img1"] and p3 in result["img1"]


def test_delete_duplicates_raw_jpg():
    with tempfile.TemporaryDirectory() as tmpdir:
        p1 = Path(tmpdir) / "img1.jpg"
        p2 = Path(tmpdir) / "img1.raw"
        p3 = Path(tmpdir) / "img1.dng"
        p4 = Path(tmpdir) / "img2.jpg"

        p1.write_bytes(b"same")
        p2.write_bytes(b"same")
        p3.write_bytes(b"same")
        p4.write_bytes(b"different")

        dupes = find_jpeg_raw_pairs([Path(tmpdir)])
        deleted = delete_duplicates(dupes, dry_run=False, keep=0)

        existing_files = list(Path(tmpdir).glob("*.jpg"))
        assert len(existing_files) == 2
        assert p1.exists()
        assert not p2.exists()
        assert not p3.exists()
        assert len(deleted) == 2
