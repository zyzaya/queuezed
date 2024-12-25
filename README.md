*to create a website that allows for a user to create, edit, and practice quizzes with a spaced repitition system.*

# versioning
*loosely uses semvar (https://semver.org/)*

- *MAJOR.MINOR.PATCH*
- *PATCH* must be incremented if only backwards compatible bugfixes are introduced. A bugfix is defined as an internal change that fixes incorrect behaviour.
- *MINOR* must be incremented if new, backwards compatible functionality is introduced. 
  - It must be incremented if any public functionality is marked as deprecated. 
  - It may be incremented if substantial new functionality or improvements are introduced to private code. 
  - It may also include PATCH level changes. 
  - PATCH version must be reset to 0 when MINOR version is incremented.
- *MAJOR* must be incremented if any backwards incompatible changes are introduced 
  - It may also include MINOR and PATCH level changes.
  - MINOR and PATCH versions must be reset to 0 when MAJOR version is incremented.  

# git branches
- *main* - only contains snapshots of release versions
- *develop* - represents a state with the latest delivered development changes
- *feature* - used when developing a new feature or enhancement. Named as feature#-name. # is only added if applicable
- *issue* - used when fixing an existing issue. Named as issue#-summary
---
- *tag* - git tag vX.X.X

# test
```bin/rails test```
- runs all tests excluding system tests

```bin/rails test:system```
- runs system tests
- due to asynchronous javascript / the way tests are written, there is a possibility that a system test will fail when it shouldn't. If a test fails when running multiple tests, run that system test again by itself before concluding that something is broken.

# build
```how to build or deploy```
setup
- deployed on render.com: https://render.com/docs/deploy-rails
- build script is bin/render-build.sh
- render.yaml defines render webservice properties
- render.yaml reference: https://render.com/docs/blueprint-spec
- in render dashboard: blueprint -> new blueprint instance -> select repository

custom domain https://render.com/docs/custom-domains
- add custom domain to render webservice: https://render.com/docs/custom-domains
- configure DNS with provider: https://www.namespro.ca/KB-how-do-i-create-a-cname,-mx-or-txt-record.asp?sID=1E27D6F4198D4A188110891AD3B88358
- this takes a bit of time to propagate

deploy
- render automatically deploys commits on branch *main*


# database
To reload test/development databases:
- bin/rails db:reset