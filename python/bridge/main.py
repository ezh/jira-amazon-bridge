import logging
import os
import threading
from queue import Queue

from es import es_upload
from jira import jira_all_issues_as_a_list
from jira import jira_all_projects_as_a_list
from jira import jira_all_workloads_as_a_list
from util import split

nproc = int(os.environ['NPROC'])


def lambda_handler(event, context):
    queue = Queue()
    forward(queue, nproc)


def forward_project(project, queue):
    logging.info(f'forward project {project["key"]}')
    queue.put(jira_all_issues_as_a_list(project['key']))


def forward_workloads(workloads):
    es_upload(workloads, 'id', 'workload')


def forward_issues(issues, queue):
    es_upload(issues, 'key', 'issue')
    for issue in issues:
        queue.put(jira_all_workloads_as_a_list(issue['id'], issue))


def forward(queue, nproc):
    logging.info('process projects')
    projects = jira_all_projects_as_a_list()
    threads = [
        threading.Thread(target=forward_project, args=(project, queue))
        for project in projects
    ]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()

    issue_bucket = list()
    while not queue.empty():
        issue_bucket.extend(queue.get())

    logging.info('process issues')
    threads = [
        threading.Thread(target=forward_issues, args=(issues, queue))
        for issues in split(issue_bucket, nproc)
    ]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()

    workload_bucket = list()
    while not queue.empty():
        workload_bucket.extend(queue.get())

    logging.info('process workloads')
    threads = [
        threading.Thread(target=forward_workloads, args=(workloads,))
        for workloads in split(workload_bucket, nproc)
    ]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()


level = logging.INFO
if logging.getLogger().hasHandlers():
    # The Lambda environment pre-configures a handler logging to stderr
    # ff a handler is already configured,
    # `.basicConfig` does not execute. Thus we set the level directly.
    logging.getLogger().setLevel(level)
else:
    logging.basicConfig(level=level)
# queue = Queue()
# forward(queue, nproc)
