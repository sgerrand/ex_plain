# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0](https://github.com/sgerrand/ex_plain/compare/v0.2.0...v0.3.0) (2026-04-20)


### Features

* **client:** set a default receive_timeout of 30s ([#8](https://github.com/sgerrand/ex_plain/issues/8)) ([b82c641](https://github.com/sgerrand/ex_plain/commit/b82c641eb5f17291db07c38f84aabf586d6c8095))
* **webhooks,customer_groups:** introduce typed structs ([#9](https://github.com/sgerrand/ex_plain/issues/9)) ([5f4ac11](https://github.com/sgerrand/ex_plain/commit/5f4ac117773282bb0099bf869d0bb3fbe819c61d))


### Bug Fixes

* **client:** check for GraphQL errors before data on 200 responses ([#4](https://github.com/sgerrand/ex_plain/issues/4)) ([cece2b1](https://github.com/sgerrand/ex_plain/commit/cece2b1102bcf2a1e7a7784be98c361326e23c16))
* **components:** omit dividerSpacingSize key when no spacing_size given ([#3](https://github.com/sgerrand/ex_plain/issues/3)) ([270aecf](https://github.com/sgerrand/ex_plain/commit/270aecf59bcddd1dc4e4a01e2cb0c6b0a7a7a02b))
* **customers:** raise on unrecognised upsert result values ([#6](https://github.com/sgerrand/ex_plain/issues/6)) ([e54ec0a](https://github.com/sgerrand/ex_plain/commit/e54ec0a7ebd55b6c80759af36c97e1c75237781c))
* **date_time:** raise a clear error when iso8601 key is missing ([#7](https://github.com/sgerrand/ex_plain/issues/7)) ([3a6e603](https://github.com/sgerrand/ex_plain/commit/3a6e603b0846a64b0c56da609dc3707e6710201b))

## [0.2.0](https://github.com/sgerrand/ex_plain/compare/v0.1.0...v0.2.0) (2026-04-20)


### Features

* add core client infrastructure and shared types ([ea3f595](https://github.com/sgerrand/ex_plain/commit/ea3f595b3ec25507a88332f8027de52e27c271ca))
* add domain modules for all Plain API resources ([1a7bf06](https://github.com/sgerrand/ex_plain/commit/1a7bf06ecbc86fb7b72b6b1145350f96b6473408))
* add domain structs for all Plain API resources ([d6145a2](https://github.com/sgerrand/ex_plain/commit/d6145a21e81ef9f44c97cf490fb46f73b97a5edd))
* add ExPlain.CustomerGroups module for listing and fetching customer groups ([0e1595c](https://github.com/sgerrand/ex_plain/commit/0e1595c97702b4c4308ef6fd57248e7b335701ca))
* add GraphQL operations and component builders ([451ca0b](https://github.com/sgerrand/ex_plain/commit/451ca0b1dc6c686fc5aba294ae21e9fdba4408a0))
* implement ExPlain.new/1 entry point and add tests ([303f841](https://github.com/sgerrand/ex_plain/commit/303f84143ce2a61c2f4c999f9c80d1da97916267))

## 0.1.0 (2026-04-20)

Initial release.
