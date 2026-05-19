---
description: "Use when: handling images, OpenCV steps, or scan pipeline work."
---
# Image Handling Rules

- Never hold more than 2 full-resolution images in memory.
- Process images at <= 2048px on the longest edge.
- Thumbnails are 256px.
- Use `compute()` / isolates for image operations over 50ms.
- Delete temp files after the pipeline completes.
