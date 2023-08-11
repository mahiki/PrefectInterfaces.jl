from pathlib import Path
from prefect.blocks.core import Block
from prefect.filesystems import LocalFileSystem
from src.config import PREFECT_LOCAL_DATA_DIRNAME
from src.config import PREFECT_ENV_BLOCK

env_block = Block.load(name=PREFECT_ENV_BLOCK)

fs_block = LocalFileSystem(
    basepath=Path(Path.home()).joinpath(PREFECT_LOCAL_DATA_DIRNAME, env_block.value)
    )

fs_block.save(name="willowdata", overwrite=True)
