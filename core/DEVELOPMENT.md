# LATEST - 1.00
https://login.salesforce.com/packaging/installPackage.apexp?p0=XX
https://test.salesforce.com/packaging/installPackage.apexp?p0=XX


MANAGE PACKAGES
sf package list
sf package delete -p xxx
sf package version list --verbose
sf package version delete -p core@1.0.0-X
sf package version report --package "core@1.1.0.1"
sf package version promote --package "core@1.xx.0-1"

CREATE PACKAGE
1. create sandbox
# sf org delete scratch -o core-dev
sf org create scratch --duration-days 10 -d -f config/project-scratch-def.json -a core-dev
sf limits api display

2. push and run tests
# sf project deploy start --ignore-conflicts
sf project deploy start
sf apex test run --synchronous

3. create package
# sf package create --name "core" --path force-app --package-type Managed --description "core"

3. create package version with password
sf package version create --package "core" --code-coverage --installation-key qwe123 --wait 90 --verbose
# sf package version create --package "core" --code-coverage --installation-key qwe123 --wait 90 --verbose --skip-ancestor-check
# sf package version create --package "core" --skip-validation --installation-key qwe123 --wait 90 --verbose --skip-ancestor-check

4. test scratch
# sf org delete scratch -o core-dev.test1
sf org create scratch --duration-days 1 --edition developer --no-namespace -a core-dev.test1
sf package install --package XX --installation-key qwe123 --wait 90

5. remove/promote out of beta
# sf package version delete --package "core@1.xx.0-1"
sf package version promote --package "core@1.00.0-1"

6. install

Package Installation URL: https://test.salesforce.com/packaging/installPackage.apexp?p0=<ID HERE>
As an alternative, you can use the "sf package:install" command.

7. git tag
git tag -a core-1.00 -m "core-1.00"