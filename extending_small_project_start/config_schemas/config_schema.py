from data_module_schema import DataModuleConfig
from hydra.core.config_store import ConfigStore
from omegaconf import MISSING
from pydantic.dataclasses import dataclass


@dataclass
class Config:
    data_module: DataModuleConfig = MISSING
    task: task_schema.TaskConfig = MISSING
    trainer: trainer_schema.TrainerConfig = MISSING


def setup_config() -> None:
    cs = ConfigStore.instance()
    cs.store(name="config_schema", node=Config)
