# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [2.5.2-bb.4] - 2025-06-09

### Changed

- Updated backstage 1.0.7 -> 1.0.8
- Updated gluon 0.5.21 -> 0.6.2

## [2.5.2-bb.3] - 2025-06-04

### Changed

- Removed un-declared field from istio Sidecar

## [2.5.2-bb.2] - 2025-06-02

### Changed

- Added Istio Operator-less network policy support

## [2.5.2-bb.1] - 2025-05-22

### Changed

- update backstage image from 1.0.5 -> 1.0.7
- update gluon 0.5.19 -> 0.5.21

## [2.5.2-bb.0] - 2025-05-14

### Changed

- update gluon 0.5.15 -> 0.5.19
- update backstage chart 2.5.1 -> 2.5.2

## [2.5.1-bb.2] - 2025-04-25

### Changed

- update image from ironbank/big-bang/backstage 1.0.4 -> 1.0.5

## [2.5.1-bb.1] - 2025-04-21

### Added

- added prometheus networkpolicy for target health scraping

## [2.5.1-bb.0] - 2025-04-18

### Changed

- configured renovate
- update gluon 0.5.14 -> 0.5.15
- update backstage chart 1.9.6 -> 2.5.1
- remove postgresql deployment for chart
- update istio resource apiVersion references to v1
- add bigbang annotations
- update registry to ironbank/big-bang/ namespace for compiled bigbang managed framework image
- default guest access to enabled
- remove keycloak refs for catalog backend

## [1.9.6-bb.11] - 2025-04-17

### Changed

- Fix for istio sidecar template for BB umbrella CI

## [1.9.6-bb.10] - 2025-04-11

### Added

- Added network policies required for umbrella chart operation

## [1.9.6-bb.9] - 2025-04-10

### Changed

- Migrated application source code to <https://repo1.dso.mil/big-bang/apps/developer-tools/backstage>

## [1.9.6-bb.8] - 2025-03-28

### Added

- backstage resource limits and requests settings for QoS in values.yaml
- slightly smaller backstage resource limits and requests settings for QoS in test-values.yaml

## [1.9.6-bb.7] - 2025-04-03

### Added

- helm tests
- cypress test

## [1.9.6-bb.6] - 2025-03-25

### Added

- initial keycloak plugin

## [1.9.6-bb.5] - 2025-03-21

### Added

- backstage resource limits and requests settings for QoS in values.yaml
- slightly smaller backstage resource limits and requests settings for QoS in test-values.yaml

## [1.9.6-bb.4] - 2025-03-13

### Added

- base deployment component, kyverno policy component, base API relations

## [1.9.6-bb.3] - 2025-02-27

### Added

- initial grafana plugin

## [1.9.6-bb.2] - 2025-02-14

### Added

- initial k8s plugin resources and config

## [1.9.6-bb.1] - 2025-02-05

### Added

- bigbang chart templates for istio

## [1.9.6-bb.0] - 2025-01-29

### Added

- README.md
