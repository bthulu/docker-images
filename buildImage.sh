#!/bin/bash
docker build --shm-size=2g --build-arg DB_EDITION=EE -t bthulu/oracledb:11.2.0.4 .
