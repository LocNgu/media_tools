import tempfile
from pathlib import Path

from media_tools.controller import run_dedup, run_raw_cleanup


def testrun_dedup():
    with (
        tempfile.TemporaryDirectory() as tmpdir1,
        tempfile.TemporaryDirectory() as tmpdir2,
    ):
        p1 = Path(tmpdir1) / "file1.jpg"
        p2 = Path(tmpdir2) / "file1.jpg"

        p1.write_bytes(b"same")
        p2.write_bytes(b"same")

        deleted = run_dedup([Path(tmpdir1), Path(tmpdir2)], mode="name", dry_run=False)
        assert p2 in deleted


def test_run_raw_cleanup():
    with tempfile.TemporaryDirectory() as tmpdir:
        p1 = Path(tmpdir) / "img1.jpg"
        p2 = Path(tmpdir) / "img1.raw"
        p3 = Path(tmpdir) / "img1.dng"
        p4 = Path(tmpdir) / "img2.jpg"

        p1.write_bytes(b"same")
        p2.write_bytes(b"same")
        p3.write_bytes(b"same")
        p4.write_bytes(b"different")

        deleted = run_raw_cleanup([Path(tmpdir)], dry_run=False)
        assert len(deleted) == 2
