#!/bin/bash
#
# This assumes all of the OS-level configuration has been completed and git repo has already been cloned
#
# This script should be run from the repo's deployment directory
# cd deployment
# ./run-unit-tests.sh
#
maxrc=0
rc=0
export overrideWarningsEnabled=false

[[ $1 == 'update' ]] && {
    update="true" 
    echo "UPDATE MODE: CDK Snapshots will be updated. CDK UNIT TESTS WILL BE SKIPPED"
} || update="false"

#!/bin/bash
echo 'Installing required Python testing modules'
pip install -r ./testing_requirements.txt

# Get reference for all important folders
template_dir="$PWD"
source_dir="$template_dir/../source"
temp_source_dir="$template_dir/temp/source"

if [[ -e './solution_env.sh' ]]; then
    chmod +x ./solution_env.sh
    source ./solution_env.sh
else
    echo "solution_env.sh is missing from the solution root."
    exit 1
fi

if [[ -z "$SOLUTION_ID" ]]; then
    echo "SOLUTION_ID is missing from ../solution_env.sh"
    exit 1
else
    export SOLUTION_ID
fi

if [[ -z "$SOLUTION_NAME" ]]; then
    echo "SOLUTION_NAME is missing from ../solution_env.sh"
    exit 1
else
    export SOLUTION_NAME
fi

if [[ -z "$SOLUTION_TRADEMARKEDNAME" ]]; then
    echo "SOLUTION_TRADEMARKEDNAME is missing from ../solution_env.sh"
    exit 1
else 
    export SOLUTION_TRADEMARKEDNAME
fi

echo "------------------------------------------------------------------------------"
echo "[Test] CDK Unit Tests"
echo "------------------------------------------------------------------------------"
cd $temp_source_dir
[[ $update == "true" ]] && {
    npm run test -- -u
    cp -f test/__snapshots__/* $source_dir/test/__snapshots__/
    cp -f playbooks/CIS120/test/__snapshots__/* $source_dir/playbooks/CIS120/test/__snapshots__/
    cp -f playbooks/AFSBP/test/__snapshots__/* $source_dir/playbooks/AFSBP/test/__snapshots__/
    cp -f playbooks/PCI321/test/__snapshots__/* $source_dir/playbooks/PCI321/test/__snapshots__/
    cp -f remediation_runbooks/test/__snapshots__/* $source_dir/remediation_runbooks/test/__snapshots__/
} || {
    npm run test
    rc=$?
    if [ "$rc" -ne "0" ]; then
      echo "** UNIT TESTS FAILED **"
    else
      echo "Unit Tests Successful"
    fi
    if [ "$rc" -gt "$maxrc" ]; then
        maxrc=$rc
    fi
}

echo "------------------------------------------------------------------------------"
echo "[Test] Python Unit Tests - Orchestrator Lambdas"
echo "------------------------------------------------------------------------------"
cd ${temp_source_dir}/Orchestrator

# setup coverage report path
mkdir -p ${temp_source_dir}/test/coverage-reports
coverage_report_path=${template_dir}/test/coverage-reports/OrchestratorLambda.coverage.xml
echo "coverage report path set to $coverage_report_path"

# Use -vv for debugging
python3 -m pytest --cov --cov-report=term-missing --cov-report "xml:$coverage_report_path"
rc=$?

if [ "$rc" -ne "0" ]; then
  echo "** UNIT TESTS FAILED **"
else
  echo "Unit Tests Successful"
fi
if [ "$rc" -gt "$maxrc" ]; then
    maxrc=$rc
fi

# The pytest --cov with its parameters and .coveragerc generates a xml cov-report with `coverage/sources` list
# with absolute path for the source directories. To avoid dependencies of tools (such as SonarQube) on different
# absolute paths for source directories, this substitution is used to convert each absolute source directory
# path to the corresponding project relative path. The $source_dir holds the absolute path for source directory.
sed -i -e "s,<source>${temp_source_dir}/Orchestrator,<source>deployment/temp/source/Orchestrator,g" $coverage_report_path

echo "------------------------------------------------------------------------------"
echo "[Test] Python Unit Tests - LambdaLayers"
echo "------------------------------------------------------------------------------"
cd ${temp_source_dir}/LambdaLayers

# setup coverage report path
mkdir -p ${template_dir}/test/coverage-reports
coverage_report_path=${template_dir}/test/coverage-reports/LambdaLayers.coverage.xml
echo "coverage report path set to $coverage_report_path"

# Use -vv for debugging
python3 -m pytest --cov=${temp_source_dir}/LambdaLayers --cov-report=term-missing --cov-report "xml:$coverage_report_path"
rc=$?

if [ "$rc" -ne "0" ]; then
  echo "** UNIT TESTS FAILED **"
else
  echo "Unit Tests Successful"
fi
if [ "$rc" -gt "$maxrc" ]; then
    maxrc=$rc
fi

# The pytest --cov with its parameters and .coveragerc generates a xml cov-report with `coverage/sources` list
# with absolute path for the source directories. To avoid dependencies of tools (such as SonarQube) on different
# absolute paths for source directories, this substitution is used to convert each absolute source directory
# path to the corresponding project relative path. The $source_dir holds the absolute path for source directory.
sed -i -e "s,<source>${temp_source_dir}/LambdaLayers,<source>deployment/temp/source/LambdaLayers,g" $coverage_report_path

echo "------------------------------------------------------------------------------"
echo "[Test] Python Scripts for Remediation Runbooks"
echo "------------------------------------------------------------------------------"
cd ${temp_source_dir}/remediation_runbooks/scripts

# setup coverage report path
mkdir -p ${temp_source_dir}/test/coverage-reports
coverage_report_path=${template_dir}/test/coverage-reports/RemediationRunbooks.coverage.xml
echo "coverage report path set to $coverage_report_path"

# Use -vv for debugging
python3 -m pytest --cov --cov-report=term-missing --cov-report "xml:$coverage_report_path"
rc=$?

if [ "$rc" -ne "0" ]; then
  echo "** UNIT TESTS FAILED **"
else
  echo "Unit Tests Successful"
fi
if [ "$rc" -gt "$maxrc" ]; then
    maxrc=$rc
fi

# The pytest --cov with its parameters and .coveragerc generates a xml cov-report with `coverage/sources` list
# with absolute path for the source directories. To avoid dependencies of tools (such as SonarQube) on different
# absolute paths for source directories, this substitution is used to convert each absolute source directory
# path to the corresponding project relative path. The $source_dir holds the absolute path for source directory.
sed -i -e "s,<source>${temp_source_dir}/remediation_runbooks,<source>deployment/temp/source/remediation_runbooks,g" $coverage_report_path

echo "------------------------------------------------------------------------------"
echo "[Test] Python Scripts for Playbook Scripts"
echo "------------------------------------------------------------------------------"
for playbook in `ls ${temp_source_dir}/playbooks`; do
    if [ $playbook == 'NEWPLAYBOOK' ]; then
        continue
    fi
    cd ${temp_source_dir}/playbooks/$playbook/ssmdocs/scripts

    # setup coverage report path
    mkdir -p ${temp_source_dir}/test/coverage-reports
    coverage_report_path=${template_dir}/test/coverage-reports/Playbook${playbook}.coverage.xml
    echo "coverage report path set to $coverage_report_path"

    # Use -vv for debugging
    python3 -m pytest --cov --cov-report=term-missing --cov-report "xml:$coverage_report_path"
    rc=$?
    if [ "$rc" -ne "0" ]; then
      echo "** UNIT TESTS FAILED **"
    else
      echo "Unit Tests Successful"
    fi
    if [ "$rc" -gt "$maxrc" ]; then
        maxrc=$rc
    fi
    # The pytest --cov with its parameters and .coveragerc generates a xml cov-report with `coverage/sources` list
    # with absolute path for the source directories. To avoid dependencies of tools (such as SonarQube) on different
    # absolute paths for source directories, this substitution is used to convert each absolute source directory
    # path to the corresponding project relative path. The $source_dir holds the absolute path for source directory.
    sed -i -e "s,<source>${temp_source_dir}/playbooks/${playbook},<source>deployment/temp/source/playbooks/${playbook},g" $coverage_report_path

done

echo "========================================================================="
if [ "$maxrc" -ne "0" ]; then
  echo "** UNIT TESTS FAILED **"
else
  echo "ALL UNIT TESTS PASSED"
fi

exit $maxrc
