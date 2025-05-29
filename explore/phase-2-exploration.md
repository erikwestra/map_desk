# 🧠 Project Context for Second LLM: MapDesk Phase Two

## 📍 Overview

The user has built a macOS desktop application using **Flutter**, called **MapDesk**. The current (Phase One) app is a **single-purpose GPX viewer**: it allows the user to drag and drop a GPX file and view the route on a map using online basemaps.

The user now wants to expand the app in **Phase Two** into a **segment-based route builder for cyclists**. This will allow them to create custom GPX routes from a database of known and trusted track segments. The goal is to support **manual segment creation** and a **map-first route assembly experience**.

This document summarizes the updated scope and vision, which has already been clarified and approved by the user.

---

## 🚩 Updated North Star

> To create the fastest, cleanest way to build a custom cycling route from trusted track segments.

MapDesk will now enable cyclists to **split imported GPX files into reusable segments**, save those segments with direction and names, and later **assemble full routes** by clicking from segment to segment on an interactive map.

---

## 🧭 Project Goals (Phase Two)

MapDesk Phase Two allows users to:

- Import a full GPX file of a ride
- Manually split it into named segments via a map interface
- Assign each segment a direction (A→B, B→A, or bidirectional)
- Add those segments to a **local-only database**
- Enter "Assemble Mode" where the user can:
  - Start building a new route by clicking a start point
  - View all valid segments that continue from the current point
  - Click to add segments one-by-one to a new route
  - Save the assembled route as a GPX file

---

## 🧱 Design Principles

| Principle                | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| Map-first interaction    | All planning happens through the map, not list views                        |
| Segment-based planning   | Encourage reusing familiar routes, not redrawing from scratch               |
| Zero-cloud simplicity    | Local-only segment storage and route planning                               |
| Iterative assembly       | Users build routes one step at a time with immediate visual feedback        |
| Speed & trust            | Assembling a known route should take under a minute                         |

---

## ✨ Core Features

### 1. GPX Segment Management
- Import a full GPX ride
- Manually split the ride into logical segments via a map interface
- Assign each segment:
  - A name
  - A direction: A→B, B→A, or bidirectional
- Add selected segments to a local database

### 2. Segment Database
- Store all segments locally
- Support basic filtering/searching by name or location
- Allow visual preview of segments on map

### 3. Route Assembly Mode
- Switch into "Assemble" mode
- Click on a start point — app displays valid connecting segments
- User adds segments one-by-one
- Final assembled path is saved as a `.gpx` file

---

## 🧩 Component Overview

| Component                | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| Segment Split Tool       | UI for breaking a full ride into discrete segments                          |
| Segment Metadata Editor  | Assigns name and direction before saving to database                        |
| Segment Database Store   | Local store of segments with quick lookup and filtering                     |
| Assemble Mode Engine     | Interactive tool for building routes by clicking from segment to segment    |
| Assembled Route Exporter | Converts assembled path into a GPX file for export                          |

---

## ✅ Summary

This expanded version of MapDesk transforms it into a **route planning tool for cyclists** that prioritizes **speed, reusability, and visual clarity**. The user interface will center around an interactive map that lets the user build up a route step-by-step using **known, manually defined segments**, making route creation efficient and reliable.

This document reflects the user's final exploration. You may now proceed to generate a milestone-based implementation plan, select appropriate data structures and Flutter plugins, and propose a UI layout to support this workflow.