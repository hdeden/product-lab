# Progress Log - HRIS Design Extraction (Figma Site)

## Context
- Source URL: https://shade-award-82775713.figma.site
- Goal: Extract UI design details to align the Flutter HRIS app.

## What Was Extracted
- Figma Sites bundle (JS/CSS) used to infer layout, components, and styling.
- Design summary: Mobile HRIS app (Indonesian locale), card-first UI with gradient headers, rounded surfaces, soft shadows, and reserved space for fixed bottom navigation.

## Screens / Routes Identified
- /
- /login
- /attendance
- /attendance/history
- /attendance/clock
- /requests
- /requests/leave
- /requests/overtime
- /requests/late-early
- /requests/status
- /payslip
- /payslip/:id
- /profile

## Core Components Noted
- Gradient header blocks
- Stat cards and list cards
- Info callouts / notices
- Status chips (pending/approved/rejected)
- Collapsible sections (earnings/deductions)
- Icon buttons and primary CTAs
- Forms / inputs
- Bottom navigation (implied by spacing + positioning)

## Visual System (Tailwind Classes Observed)
- Primary colors: bg-blue-600, gradients from-blue-600 to-blue-800, text-blue-600/700/800/900
- Neutrals: bg-gray-50, text-gray-900, text-gray-500
- Status colors:
  - Green: bg-green-50/500, text-green-700
  - Orange: bg-orange-50, text-orange-700
  - Red: bg-red-50, text-red-700
  - Yellow: bg-yellow-50, text-yellow-900
  - Purple: bg-purple-50, text-purple-600
- Surface: bg-white, bg-white/20
- Typography sizes: text-xs, text-sm, text-lg, text-xl, text-2xl, text-3xl
- Spacing: px-6, p-4/5/6, gap-2/3/4, space-y-2/3/4, mb-3/4/6
- Radius: rounded-2xl, rounded-xl, rounded-full
- Shadows: shadow-sm, shadow-lg, shadow-xl
- Motion: transition-colors, transition-shadow, hover:shadow-md

## Pending Decision
- Choose deliverable format for Flutter alignment:
  - Design delta doc
  - Flutter-ready tokens (JSON/YAML)
  - Component spec sheet
  - Screen-by-screen layout notes

## Notes
- Extraction derived from Figma Sites runtime bundle and CSS. No screenshots captured yet.
