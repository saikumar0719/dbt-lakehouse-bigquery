"""Daily dbt DAG (Airflow / Cloud Composer 3).

Runs the full dbt build (models + tests), then generates docs from the
fresh manifest. A failed test fails the build task, so bad data never
reaches the gold marts and stale docs are never published.

Deploy: copy to your Composer environment's dags/ folder and point
DBT_PROJECT_DIR at the deployed dbt project.
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    "owner": "lakehouse",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "sla": timedelta(hours=1),
}

with DAG(
    dag_id="dbt_lakehouse_daily",
    default_args=default_args,
    start_date=datetime(2026, 10, 27),
    schedule_interval="@daily",
    catchup=False,
    tags=["dbt", "lakehouse"],
) as dag:

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command="cd {{ var.value.dbt_project_dir }} && dbt build --profiles-dir .",
    )

    dbt_docs = BashOperator(
        task_id="dbt_docs_generate",
        bash_command="cd {{ var.value.dbt_project_dir }} && dbt docs generate",
    )

    dbt_build >> dbt_docs
