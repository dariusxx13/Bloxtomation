# Reel the Storm: art direction

Task T-0010 · Artist · 2026-10-25 · Stage: design · Outcome served: **click** (a look that reads as cozy fishing in stormy weather at thumbnail size), with **stay** second (it has to run on low-end phones).

**Inputs.** `loop-sketch.md` sections 1, 3, 4.1-4.2 and 5.6; `pitch.md` "Questions for the human" item 1; `market-scan.md` "IP risks"; `decisions.md` D3 and D6. Vault: `06-world-and-look/art-direction.md`, `06-world-and-look/lighting-and-atmosphere.md`, `19-vfx/vfx-performance-budgets.md`, `19-vfx/environment-and-ambient-vfx.md`, `19-vfx/lighting-and-screen-effects.md`, `19-vfx/vfx-recipes.md`, `11-store-page-and-discovery/icons.md` and `thumbnails.md`.

**Labels.** *Vault budget*: a number from the vault, with its file and line. *Starting value*: my first pass, to be tuned on a phone. *Measured*: computed for this doc, with the method given.

**Layout sketch:** [art-direction-sketch.svg](art-direction-sketch.svg) shows the palette, the three icon layouts and the thumbnail layout. It is drawn by hand from simple shapes and contains no images.

---

## 1. The look in one line

**"A lantern in the storm."** The world is cool, rounded and storm-blue, and everything you can touch, catch or celebrate glows warm gold. The style family is bright stylized and toy-like (vault art-direction table), pushed toward dusk and weather instead of the genre's bright-cyan noon. The hero object is the **Rumblefin**, the friendly Stormborn giant from the clip moment. It appears in the icon and the thumbnail, and as a weathervane you can see from spawn.

Three rules govern everything else:

1. **Cool world, warm interactables.** Sky, water and rock stay in slate, teal and seafoam. Gold and cream are reserved for things the player acts on: ripples, the bobber, lanterns, Cast, coins, and lightning in the storm.
2. **Round means safe.** Every shape is rounded. Only lightning zigzags, and lightning is always gold.
3. **Storms get the warmest light in the game.** When the sky darkens, the lanterns, windows and pier lights turn on.

## 2. Palette

| Swatch | Hex | Role | Rule |
|---|---|---|---|
| Night Ink | `#18203A` | Darkest value: storm shadows, the rim on every interactable, UI backdrop | Never pure black in the world |
| Storm Slate | `#2E3F5C` | Storm sky, deep water, UI panels | |
| Squall Teal | `#3F7F8C` | Water mid-tone, fish backs, wet rock | |
| Seafoam | `#A8DCD1` | Foam, spray, wave crests, rain streaks | |
| Moss | `#6BAA75` | Island grass, mossy roofs | Muted on purpose, so it is never mistaken for the Uncommon rarity green |
| Shell Cream | `#FFF8EC` | Painted piers and cottages, sails, UI text, bobber top | |
| Ember Coral | `#FF7A59` | Raincoats, buoys, bobber base, fish bellies, pier trim | An accent, never a background |
| Lantern Gold | `#FFC42E` | Interactables, coins, lanterns, the line in the storm | Same as the template's `Theme.colors.accent` (255, 196, 46), so the UI and the world agree |
| Bolt core / glow | `#FFF6D8` / `#FFC42E` | Lightning and the Charged mark | Lightning is never blue-white, purple or red |
| Eye Halo | `#FFD27A` | The warm gap in the clouds over the Open Pier | Great Storm only |

**Rarity tiers** keep the template's colours (`project/src/shared/Config/Pets.luau`): Common `#C8C8C8`, Uncommon `#5AD264`, Rare `#4696FF`, Epic `#AA5AFF`, Legendary `#FFBE28`, Mythic `#FF466E`, and Secret `#1E1E1E` with animated treatment. Scenery never uses these saturated hues (vault readability rule: "do not paint scenery in rarity colors").

**Weather marks** pair a colour with a shape, and the shape carries the meaning for colour-blind players:

| Mark | Colour | Shape |
|---|---|---|
| Drizzled | `#6FC3D9` | Droplet |
| Misty | `#E6ECEA` with a Night Ink rim | Soft cloud circle |
| Breezy | `#9BE3C3` | Swirl |
| Charged | `#FFC42E` with a `#FFF6D8` core | Zigzag (the only zigzag besides lightning) |
| Prism | 7-band rainbow gradient | Four-point sparkle |
| Auroral | `#7FE0C4` to `#F2A7C3` | Ribbon wave |

**Measured contrast** (WCAG contrast ratio, computed with the standard relative-luminance formula on the hex values above):

- Lantern Gold reads well on dark weather: 6.7:1 on Storm Slate, 8.2:1 on night water `#22304F` and 10.1:1 on Night Ink.
- Gold alone disappears in bright weather and fog: 1.9:1 on Clear water `#3F9FB0`, 2.3:1 on Showers water `#4E8FA3`, 1.2:1 on Gust sky `#7CC4E8` and 1.1:1 on Fog Pearl `#D4D9D2`.
- A Night Ink rim fixes that: 5.2:1 on Clear water, 4.4:1 on Showers water, 3.5:1 on Squall Teal and 11.2:1 on Fog Pearl.
- **Rule: every interactable is two-tone, with a gold or cream core and a Night Ink rim** (a ring, an outline band or a backing disc). The rim is at least 1/8 of the object's width. This covers ripple rings, lantern ripples, the bobber, the Pull button and coins.
- Ember Coral on teal water is only 1.8:1, so coral never marks an interactable on its own.
- UI text: Shell Cream on Storm Slate is 10.0:1.

## 3. Mood per weather

| Weather | Mood | Sky | Water | Light accent | What a screenshot shows |
|---|---|---|---|---|---|
| Clear | Washing-line afternoon: bright, unhurried, home | `#8FD0F0` | `#3F9FB0` | Sun `#FFF1D0` | Puffy cumulus, sparkles on the water, flags barely moving |
| Showers | Warm rain on a tin roof | `#9FB4BF` | `#4E8FA3` | Lanterns `#FFC42E` | Rain streaks, umbrellas and raincoats, brimming rock pools, a big splash on each bite |
| Sea Fog | Lanterns in milk: quiet and close, never spooky | `#D4D9D2` | `#C9D3D0` (fogged) | Lantern glow with ink rims | A soft grey wall at 40-60 studs, lantern ripples glowing through it, a big dark-rimmed bobber dip |
| Gusts | Kites and bunting: lively, crisp, far horizon | `#7CC4E8` | `#3F7F8C` with Seafoam whitecaps | Sun `#FFF1D0` | Racing clouds, whitecaps, a bowed line, snapping bunting, far water clearly visible |
| Rainbow | Sun after rain: wet, shining, a little magic | `#BFE3F0` | `#4E8FA3`, glinting | Rainbow 7-band | A rainbow arc whose foot touches one ripple, sun glints, drips from roofs |
| Great Storm | The cozy storm: dark sky, warm windows, the harbour lit for a party | `#2E3F5C` darkening to `#18203A` at the edges | `#2E4F66` | Bolt `#FFF6D8`/`#FFC42E`, lanterns, Eye Halo `#FFD27A` | A warm halo in the clouds over the Open Pier, slow gold lightning, string lights on the pier, a crowd |
| Aurora Night | A calm night under moving lights | `#18203A` | `#22304F` | Aurora `#7FE0C4` to `#F2A7C3`, lanterns | Teal-to-rose ribbons high in the sky, stars, fireflies by the lanterns, reflections in calm water |

The aurora is teal and rose, not neon green and purple, so the night never resembles Fisch's look (section 10).

## 4. Shape language

| Shape | Means | Examples |
|---|---|---|
| Circle | You can act on this | Ripple rings, the bobber, lanterns, the Cast button, coins, fish eyes, Sky Dial weather icons |
| Pebble (rounded box or blob) | The world, safe to stand on | Islands, rocks, cottages, pier planks with rounded ends, boats |
| Zigzag | Lightning and Charged only | The bolt, the Charged mark |

- **Clouds are stacked circles** (cumulus puffs). The Sky Dial icons use the same puffs, so the HUD matches the sky.
- **Nothing sharp:** no spikes, teeth, thorns, skulls, wreckage, broken masts or jagged rocks anywhere. This supports cozy rule 4 and the Minimal maturity expectation (D5).
- **Fish** are chunky and round. Body depth is 0.5-0.7 of length, the eye is 1/5 of body height with a highlight, the mouth is small and closed, and fins are paddle-shaped. Each species needs a distinct silhouette at 30 studs (vault silhouette rule).
- **Stormborn giants** are 4-5 times avatar height in length (the Rumblefin is about 22 studs). They share the friendly face.
- **The Rumblefin** has a stout body with a Squall Teal back fading to an Ember Coral belly, a Shell Cream cloud-puff dorsal fin, a gold static stripe along its side, huge round eyes and a small closed smile. It is not a shark, whale or serpent but a round, toy-like fish. A Rumblefin weathervane on the harbour master's roof is visible in the first frame, so the icon, the thumbnail and the first second of play share a hero (vault icons, "consistency with the game").
- **Companions** have big heads and small bodies (vault art-direction, "chunky with big heads for pets"). Each carries a weather prop: the Puddle Frog a leaf umbrella, the Lamp Moth a glowing abdomen, the Kite Gull a tail ribbon.
- **Buildings** are squat harbour cottages with oversized rounded roofs and round, warm-lit windows. The Open Pier is the biggest structure, and bridges and the weathervane are the landmarks (vault: "scale tells importance").

## 5. Materials

| Use | Material | Notes |
|---|---|---|
| Most props, fish, characters | `SmoothPlastic` with palette colours | Flat colour, palette only |
| Piers, cottages | `Wood` through one custom `MaterialVariant`, "PaintedPlank" (soft grain, low contrast) | Painted cream and coral. Never raw brown planks with rope-wrapped posts (section 10) |
| Rocks, rock pools | `Slate`, or a "WetPebble" `MaterialVariant` | Darkens one step in Showers and the Storm through a colour tween, not a material swap |
| Sails, bunting, umbrellas | `Fabric` | |
| Glow (ripple rings, lanterns, Charged stripe, eye halo, string lights) | `Neon` with a modest `BloomEffect` | Neon is reserved for interactables and the storm's warm lights. Neon with bloom is cheaper than lights (vault lighting-and-atmosphere, Performance) |
| Water | Terrain water, if the Worldbuilder uses it, with colour and waves tweened per weather (section 6) | With part-based water, use the colours only |

- At most 4 custom `MaterialVariant`s. Textures are 512 px for props and 1024 px only for the 4 Stormborn (vault asset-pipeline; build-budgets).
- No `SurfaceAppearance` PBR, no `Glass` (transparency overdraw) and no metal or foil.
- No outlines on scenery. `Highlight` is used only on the hooked Stormborn, one at a time.
- Lighting style: `LightingStyle = Soft`, because softer shadows suit the cozy look. `PrioritizeLightingQuality = false`, because Gusts needs far water visible (vault lighting-and-screen-effects, "Lighting style matters first"). Revisit this if lantern glow fades on low-end phones.

## 6. Lighting and Atmosphere per weather

The client applies the preset of the front at the camera's position and tweens it over 3 s. The vault suggests 1-2 s; 3 s matches the loop's 3 s storm audio swell. Other fronts in view are drawn as cloud cells (section 11). All values are starting values: tune them with phone and PC screenshots side by side (vault lighting-and-atmosphere checklist). Store them as data, as the vault requires ("named lighting preset stored as data"), for example in a `project/src/shared/Config/WeatherLook.luau` that the Engineer or Worldbuilder creates.

**Lighting and post-processing**

| Weather | ClockTime | Brightness | ExposureCompensation | OutdoorAmbient | Ambient | ColorCorrection Saturation / Contrast / TintColor | Bloom Intensity / Threshold |
|---|---|---|---|---|---|---|---|
| Clear | 14.5 | 2.6 | 0 | `#9AA9B8` | `#5A6478` | 0.10 / 0.05 / `#FFF8EE` | 0.4 / 0.95 |
| Showers | 14.5 | 1.8 | -0.1 | `#8696A6` | `#505A6E` | -0.05 / 0.05 / `#F2F6FF` | 0.6 / 0.90 |
| Sea Fog | 14.5 | 1.5 | 0 | `#A7AEAD` | `#6A7070` | -0.20 / -0.05 / `#FFF6E6` | 0.7 / 0.90 |
| Gusts | 14.5 | 2.8 | 0.05 | `#9CB3C6` | `#5A6478` | 0.12 / 0.08 / `#FFFFFF` | 0.4 / 0.95 |
| Rainbow | 15.5 | 2.4 | 0.05 | `#A6B2BE` | `#5A6478` | 0.15 / 0.05 / `#FFF4E0`; `SunRaysEffect` 0.08 / spread 0.6 | 0.5 / 0.92 |
| Great Storm | 17.0 | 1.2 | -0.25 | `#6E7FA0` | `#3C4866` | -0.10 / 0.12 / `#E6ECFF` | 0.9 / 0.85 |
| Aurora Night | 22.0 | 1.0 | 0.2 | `#5A6B8C` | `#36405E` | 0.05 / 0.05 / `#EEF2FF` | 1.0 / 0.85 |

**Atmosphere, clouds, wind and water**

| Weather | Atmosphere Density / Offset / Haze / Glare / Color / Decay | Clouds Cover / Density / Color | `Workspace.GlobalWind` | Water colour / wave size / wave speed |
|---|---|---|---|---|
| Clear | 0.25 / 0 / 1.0 / 0 / `#C8E6F0` / `#8FBFD8` | 0.45 / 0.30 / `#FFFFFF` | (3, 0, 1) | `#3F9FB0` / 0.10 / 8 |
| Showers | 0.36 / 0 / 1.8 / 0 / `#A9C4CF` / `#6E8C9A` | 0.80 / 0.55 / `#B7C3CC` | (6, 0, 3) | `#4E8FA3` / 0.15 / 10 |
| Sea Fog | 0.55 / 0.1 / 2.5 / 0 / `#D4D9D2` / `#B9C2BE` | 0.60 / 0.20 / `#E6E9E6` | (0.5, 0, 0) | `#6F9AA3` / 0.05 / 4 |
| Gusts | 0.20 / 0 / 0.5 / 0 / `#CFE8F2` / `#9CC9DE` | 0.55 / 0.25 / `#FFFFFF` | (20, 0, 8), turned to match the gust arrow | `#3F7F8C` / 0.30 / 16 |
| Rainbow | 0.30 / 0 / 1.2 / 0.3 / `#DDEBF0` / `#A8C8D8` | 0.40 / 0.30 / `#FFFFFF` | (3, 0, 1) | `#4E8FA3` / 0.10 / 8 |
| Great Storm | 0.42 / 0 / 2.2 / 0 / `#5D6E8C` / `#2E3F5C` | 0.95 / 0.80 / `#4A5876` | (14, 0, 6) | `#2E4F66` / 0.35 / 18 |
| Aurora Night | 0.30 / 0 / 1.0 / 0 / `#2B3A5A` / `#18203A` | 0.25 / 0.20 / `#3A4870` | (1, 0, 0) | `#22304F` / 0.05 / 5 |

- **Sea Fog** density needs the most tuning. The bobber and the nearest lantern ripple must read at maximum cast distance, and the fog wall should sit at 40-60 studs.
- **Gusts** keeps the clearest air of any weather, because its far-water ripples must be visible from the cliff.
- **Great Storm** darkens through exposure and clouds rather than Brightness alone, so avatars stay readable (vault: "keep characters visible"). The eye over the Open Pier is a ring-shaped gap in a cloud mesh with Eye Halo behind it.
- Fixed ClockTime per weather assumes no day-night cycle at launch apart from Aurora Night (section 14, question 1).

## 7. Cozy rules as visual rules

From `loop-sketch.md` section 3. Each rule has a check a playtester can run.

| Cozy promise | Visual rule | Check |
|---|---|---|
| Unhurried pace | Lighting and Atmosphere tween over 3 s. A front is visible as a slow cloud cell before it arrives. Countdowns never blink or shake. | Time a front's arrival: nothing changes faster than 3 s |
| No harsh fail states | A missed reel shows the fish's silhouette swimming off with one small ripple. No red, no X, no "FAIL", no shake, no tint. The template's red `Theme.colors.bad` is never used in fishing feedback. | Miss 5 reels on purpose: no red and no camera shake |
| Nothing taken by others | Ripple rings are about 10 studs across, wide enough for 6 bobbers, and carry no owner colour. Other players' catch effects play at the lower tier (self first). | 4 players fish one ripple: every bobber reads, no ownership marks |
| Storms are a treat, never a threat | The storm has the warmest light: lanterns, windows and string lights on. Lightning is gold and strikes only open water or the hooked fish's line, never an avatar, the pier or a building. No skulls, wrecks, hazard stripes or red. Stormborn faces are friendly and toothless. | Storm screenshot: at least 6 warm light sources in view; no strike touches an avatar |
| Calm audio (its visual partner) | Thunder pairs with a soft glow inside a cloud, never a camera shake. | No camera shake in any weather |
| Calm visuals | At most one lightning flash per 2 s, soft (0.4 s or less), never a strobe (vault: "at most one bright full-screen flash per moment"). With Reduce Motion on (the template's `reduceMotion` setting, plus `GuiService.ReducedMotionEnabled`) there is no exposure flash and no light pulse: the bolt shows at half opacity and the line glows steady gold for the tap window. Night and fog stay readable: the water area of a phone screenshot averages at least 64/255 grey, and every interactable keeps its Night Ink rim (at least 3.5:1 against water, section 2). | Measure phone screenshots in Sea Fog, Great Storm and Aurora Night |
| Social warmth | Each helper's Pull taps draw a thin gold thread (`Beam`) from the helper to the line, so the co-op is visible. The Cheer emote throws warm confetti. Banners are gold on slate and use celebratory words only. | A clip of 4 players pulling shows 4 threads |
| Honest time | Countdowns look the same at 5:00 and at 0:05: no red, no pulse. Every front on the Sky Dial has a cloud cell in the sky in the same direction. A summoned front (D6) looks exactly like a natural one in the sky; only the Sky Dial adds a small "called by" tag, so the sky never lies. | Compare the Sky Dial with the sky |

## 8. References, described in words

These are public-domain artworks, real places and real objects, not other games. No reference image is imported into the game or this repository. Any later reference sheet uses our own Studio captures (vault art-direction, style guide item 8).

1. **Painted harbour towns:** the colourful wooden row houses of North Atlantic fishing towns (for example St. John's, Newfoundland) and the red fishing cabins of Lofoten, Norway. Aim for saturated paint on simple box shapes, white trim, and warm windows against a grey sea.
2. **Winslow Homer, *Breezing Up (A Fair Wind)* (1873-76).** Aim for wind you can see: a heeled boat, a taut sail, whitecaps, a clean sky. This is the Gusts mood.
3. **Katsushika Hokusai, *The Great Wave off Kanagawa* (about 1831).** Aim for waves as graphic curls with foam in scallops. We round the claw-like foam fingers into puffs, because round means safe.
4. **J. M. W. Turner, *Snow Storm: Steam-Boat off a Harbour's Mouth* (1842).** Aim for a vortex of dark cloud with warm light at its centre. This is the eye over the Open Pier.
5. **Glass fishing floats and hurricane lanterns.** Aim for glowing round objects with a dark rim: the ripple rings and lantern ripples.
6. **Wooden bath toys and tin toy boats.** Aim for chunky, rounded, painted shapes with nothing sharp: the fish and the boats.
7. **Coastal fog banks rolling into a harbour.** Aim for a soft grey wall at a distance with lamps glowing through it, while near things stay crisp.
8. **Aurora photographs over northern fishing villages.** Aim for slow ribbons high in the sky, reflections in still water and warm cabin windows below.
9. **A rainbow over a wet harbour after a shower.** Aim for shining wet surfaces and sun glints on puddles.

One association to avoid: a lone small figure in a yellow hooded raincoat in the dark reads as a well-known horror game's protagonist. Our raincoats are coral, and avatars are shown in daylight or lantern light.

## 9. Icon and thumbnail concepts

Icon specs: 512×512, previewed at 150 px and 48 px next to the genre's icons (vault icons), with no text. Layouts are in [art-direction-sketch.svg](art-direction-sketch.svg).

### Concept A: "Rumblefin Breach" (recommended)

- **Composition:** The Rumblefin leaps out of the water in a C-curve and fills about 70% of the frame. Its tail is in the water at lower left, and its head is at upper right, turned three-quarters toward the viewer with a delighted face (wide eyes, small open smile, no teeth). Eye Halo glows behind its head and separates the silhouette from the sky. A taut gold line enters from the right edge to its mouth, and one short gold bolt touches the line. Seafoam spray in round puffs fills the bottom third, and a soft vignette darkens the corners to Night Ink.
- **Palette:** Storm Slate and Night Ink background, Eye Halo, the fish in Squall Teal, Ember Coral and Shell Cream with its gold stripe, Lantern Gold line and bolt with Bolt core, Seafoam spray.
- **One-second read:** "a giant, happy fish caught in a storm".
- **Strengths:** one hero, scale, emotion on a face, the game's promise, and a slate-and-gold pairing that no fishing leader uses (section 10).
- **Risk:** there is no avatar, so viewers may not read "you catch it". The line carries that.

### Concept B: "Lantern Angler"

- **Composition:** A close-up of a cheerful avatar in three-quarter view, upper body filling 60% of the frame, wearing a coral sou'wester hat and raincoat and laughing. Both hands hold the rod, which bends to the upper left, where a gold bolt meets the line. Rain streaks run diagonally, and lantern light warms the face from below right.
- **Palette:** Storm Slate background, Ember Coral coat, Shell Cream brim lining, Lantern Gold bolt and lantern, Night Ink outlines.
- **One-second read:** "someone having fun fishing in a storm".
- **Risk:** an avatar holding a rod is the icon subject of all three fishing pages checked (Fish It!, Deep Fishing and Fisch, section 10). Even with a happy face and no dock, this is the concept closest to the leaders.

### Concept C: "Storm in a Bobber"

- **Composition:** A big round bobber (cream top, coral base, Night Ink band) floats in the centre on a gold ripple ring with an ink rim. A small puffy storm cloud directly above rains on it, and one gold zigzag runs from the cloud to the water beside the bobber. Flat graphic, big shapes.
- **Palette:** Night Ink to Storm Slate background, Shell Cream and Ember Coral bobber, Lantern Gold bolt and ring, Seafoam rain.
- **One-second read:** "fishing plus weather".
- **Strengths and risk:** it reads even at 48 px and works as a logo mark (Sky Dial, loading screen). It has no scale, no emotion and no promise of a giant.

**Measured, small-size test of the layouts.** I rendered the sketch's three icon layouts and downscaled them to 150 px and 48 px, in colour and in greyscale.

- **A:** the fish's silhouette separates by value from both the halo and the sky (relative luminance 0.18 for the teal body, 0.69 for the halo and 0.05 for slate). The thin line and bolt vanish at 48 px, so in the final art they need strokes of at least 16 px at 512 px (about 3% of the width).
- **B:** the face reads at 150 px. At 48 px it is a generic avatar.
- **C:** reads best of the three at 48 px.

**Recommendation: Concept A, "Rumblefin Breach".** It shows the clip moment's hero and matches the thumbnail and the weathervane at spawn. It also breaks the leaders' avatar-on-a-dock formula. Icons are one per locale, so B and C should be tested as two of the 3-5 Home thumbnails under personalization, not as icons; the vault says to apply the winning concept back to the icon (thumbnails, step 4). C also becomes the in-game logo mark.

### Thumbnail for the clip moment: "Five on the Pier"

1920×1080, captured from a real Great Storm landing in Studio with freecam, then composited with glow and depth of field only (vault thumbnails, production workflow). Everything shown exists in the game (`loop-sketch.md` 4.4 and 5.6).

- **Left half:** the Rumblefin at the top of its leap, its body arcing from the water at lower left to its head at upper centre-left, turned toward the pier, with sheets of seafoam spray.
- **Upper centre:** one gold bolt from the cloud to the taut line, the only bright flash. Eye Halo sits behind the fish's head.
- **Right third, at mid-height (not at the bottom):** five avatars on the cream-and-coral painted Open Pier, seen from the water at a low three-quarter angle. They lean back together and cheer. Warm string lights run along the rail, and thin gold Pull threads run from each helper to the line.
- **The line:** one taut, gold-lit diagonal from the crowd on the right to the fish's mouth on the left.
- **Bottom 15%:** water and spray only, because player counts can cover the bottom (vault thumbnails, specs).
- **Text:** none in the first version. A variant adds one word, "CHARGED!", at top right in upright rounded letters (FredokaOne), cream with a Night Ink stroke.
- **One-second read:** "a crowd landing a giant fish in a storm". It has surprise, scale, emotion and reads without UI or sound (vault clip-moments).
- **Second thumbnail, for personalization:** a Prism catch, a sparkle-marked fish leaping at the rainbow's foot in bright light after rain. It tests a sunny mood against the storm.

**Wordmark rules for "Reel the Storm"** (thumbnail variants, loading screen, in-world signs): upright letters, never italic; rounded (FredokaOne or a hand-drawn rounded wordmark); Shell Cream fill with a Night Ink stroke; "Reel" and "Storm" in the same weight; no lightning cutting through letters; no chrome. A small cloud puff may sit over the "o" if it still reads at 150 px.

## 10. Look-alike check (2026-10-25)

**Method.** On 2026-10-25 between 09:17 and 09:18 UTC I downloaded the four public game pages at `roblox.com/games/<placeId>` without signing in. I also downloaded the icon and thumbnail images those pages display, which Roblox's public thumbnail service (`thumbnails.roblox.com`, no sign-in) serves, and viewed every image. That was 4 icons and 28 thumbnails. Place ids come from the committed phone snapshot `games/stormcatch/docs/evidence/charts-2026-10-24/20261024T192617Z-high_end_phone-all.json.gz`. No image was saved to this repository: the images belong to their creators and were only looked at. No paid or credit-based tool was used.

| Game (universe, place) | What its public page shows | What our icon and thumbnails must avoid |
|---|---|---|
| **Ride Storm** (4420562665, 12593620250) | **Not a fishing game.** The page calls it "an open-world motorcycle racing game" with "over 90 motorcycles" and "Dynamic weather and special events". Icon: a chrome, italic, heavy "RIDE STORM" wordmark with a swoosh through the R, above a red superbike on a white-grey studio floor. Its 4 thumbnails show superbikes on white studio backgrounds in red-white-black and green-black liveries, the italic wordmark in white or green with a slash, and a red-suited rider. | Italic, slanted, chrome or metallic lettering; a lightning or speed slash through letters; "STORM" as the dominant word; red-black-white racing palettes; white studio backgrounds; vehicles as the hero. Beyond the word "Storm", nothing overlaps with our look. |
| **Fisch** (5750914919, 16732694052) | Icon: a shocked classic avatar holding a glowing red rod on a dark wooden walkway, beside a huge dark creature with a white edge line and purple glow, with a green light shaft, candles and pumpkins. Its 10 thumbnails are seasonal scenes (a Halloween witch in a candlelit cave, birthday confetti, a beach, autumn, Christmas). They show large stylised serpent- and dragon-like creatures with glowing edge lines, a crystal-blue creature in space, and a chunky yellow "FISCH" wordmark with a dark outline. | Neon purple and green glow on dark backgrounds; glowing edge lines on creatures; caves; serpent- or dragon-shaped giants; a chunky yellow wordmark with a black outline. |
| **Fish It!** (6701277882, 121864768012064) | **The icon and all 10 thumbnails use one template:** the same avatar on a wooden plank dock in the lower-left corner, leaning back with gritted teeth and tears, a black rod bent in an arc to the right, where a giant creature with open toothed jaws and glowing eyes breaches. The sky is cyan by day or purple at night. | The angler-lower-left, monster-right split; a strained or panicking face; raw plank docks with rope-wrapped posts in a foreground corner; a black rod arcing across the frame; open jaws, teeth and glowing eyes. |
| **Deep Fishing** (10526853622, 132239307080610) | Icon: a shocked avatar with a gold rod on a dock, a column of green money-per-second numbers, and a big hourglass with "12H" on top. Its 4 thumbnails repeat the avatar-on-a-dock-at-left formula with a giant blocky octopus or an eye in a dark hole. They also show big green "$967,428,192/s" money text, a rainbow "SECRET" word, a "YOU" label, a view from inside a toothed mouth, and a depth cross-section in layered water bands. | Money-per-second numbers, rarity words in rainbow letters, "YOU" labels, timers and hourglasses, inside-the-mouth views, water cross-sections. |

**Genre pattern across the three fishing pages:** an avatar with a rod in the foreground (in all three icons the avatar's face is shocked or strained), a monster with teeth, and either saturated cyan water or neon on dark. **Our counter:**

- a slate-and-gold storm palette;
- joyful faces, never shocked or strained ones;
- a friendly, toothless fish;
- a crowd instead of a lone angler, with the fish on the left and the anglers on the right;
- a painted cream-and-coral pier;
- no numbers.

**For the human's pitch question 1 (title look-alike):** Ride Storm is a motorcycle racing game, and the only shared element is the word "Storm". This is information for the Director to pass on. The title stays the human's decision (D3).

## 11. VFX budget per weather (low-end phone)

**Vault budgets, low-end phone** (`vault/19-vfx/vfx-performance-budgets.md`, lines 33-42):

- 300-500 live particles on screen for the whole scene;
- 2-4 unique flipbook textures;
- 4-6 dynamic lights near the camera, with no shadows;
- 20 effect meshes alive at once;
- 1-2 full-screen transparent layers;
- effect frame time under 2 ms;
- the engine cap of 100 particles per second per emitter on mobile.

Particle count is rate × lifetime (same file, line 47). The vault's guidance for weather and lightning:

- Ambient emitters run at 2-10 per second (`environment-and-ambient-vfx.md`, line 82).
- Rain is a 60×60-stud box that follows the camera on the client (`environment-and-ambient-vfx.md`, line 42; `vfx-recipes.md`, recipe 22).
- Lightning is Beams between 6-8 attachments with `Segments` 3 and `FaceCamera` (`vfx-recipes.md`, recipe 13; `beams-trails-and-highlights.md`, line 36).
- A lightning flash is a `PointLight` at the strike plus a brief exposure bump on one client (`lighting-and-screen-effects.md`, line 32), with at most one bright full-screen flash per moment (same file, line 97).

**Our split:** we design to the low end of the vault's range, 300 live particles. The weather may use at most **180** (60%), and catch, reward and companion effects keep **120** for the peak moment. Only the weather at the camera renders particles. Other fronts show as distance-tier cloud cells (vault technique 4).

| Weather | Particles at full tier (emitters × rate × lifetime = live) | Atmosphere and lighting change | Lightning | Lights, meshes, beams, full-screen layers | Low-quality tier |
|---|---|---|---|---|---|
| Clear | Water sparkles 1 × 4/s × 1.5 s = **6** | Base preset | None | 0 lights | No sparkles: 0 |
| Showers | Rain 2 × 100/s × 0.45 s = 90 (box 60×60 studs, 25 studs above the camera, speed 60, drops die at the water); splashes 1 × 30/s × 0.3 s = 9; bite splash `Emit(8)`. **About 110** | 3 s tween to Showers | None | 0 lights. Rock pools fill by tweening existing parts | 1 rain emitter (45), no ground splashes: about 55 |
| Sea Fog | Ground mist 2 × 3/s × 4 s = 24, large soft particles at 0.88 transparency; bobber-dip burst `Emit(6)`. **About 30** | The fog is `Atmosphere`, never particles or quads in front of the camera (vault technique 7) | None | Lantern-ripple `PointLight`s: at most 4 near the camera, range 10, shadows off | No mist, Atmosphere only: 0-6 |
| Gusts | Wind streaks 1 × 6/s × 1.2 s = 8; whitecaps 2 × 5/s × 1 s = 10; cliff spray 1 × 4/s × 1 s = 4. **About 22** | `GlobalWind` turns with the gust arrow and moves clouds and particles at no extra particle cost | None | Wind arrow and bowed line: 2 Beams | No whitecaps: about 12 |
| Rainbow | Sparkles at the foot 1 × 8/s × 1 s = 8; mist 1 × 2/s × 3 s = 6. **About 14** | `SunRaysEffect` 0.08 on | None | The rainbow is 1 wide Beam with a 7-band gradient; 0 lights | Sparkles only: 8 |
| Great Storm | Rain as in Showers, 90 + 9; static sparks on the hooked line 1 × 10/s × 0.5 s = 5; breach splash `Emit(30)` once (1 s life). **About 135 at peak.** The landing confetti `Emit(60)` and the Charged burst come out of the 120 reward budget. | 3 s tween. The eye halo is a mesh with Neon. String lights are Neon with bloom, not lights | One bolt at a time, at least 2 s apart: 7 attachments, 6 Beams, `Segments` 3, `FaceCamera`, offsets re-randomised twice in 0.15 s, fade 0.25 s. One `PointLight`, range 30, brightness 3 to 0 in 0.35 s, shadows off. Camera `ColorCorrectionEffect` Brightness +0.15 for 0.08 s, back over 0.4 s. **Reduce Motion:** no brightness bump and no light pulse; the bolt shows at half opacity and the line glows steady gold. | Lights: at most 4 (1 strike, up to 3 pier lanterns). Meshes: at most 8 (eye ring, up to 6 front cells). One `Highlight` on the hooked fish. Pull threads: at most 11 Beams. Full-screen layers: 0, because the flash is post-processing | 1 rain emitter (45), splashes 9, breach `Emit(30)`, no static sparks: about 85. Landing confetti drops to `Emit(30)` |
| Aurora Night | Fireflies by the lanterns 1 × 3/s × 3 s = 9; water glints 1 × 4/s × 1.5 s = 6. **About 15** | Night preset; stars from `Sky` | None | The aurora is 3 high Beams sharing one grayscale soft texture tinted teal to rose, `TextureSpeed` 0.05, transparency 0.55. Lanterns: at most 4 `PointLight`s, shadows off | No fireflies, 2 aurora Beams |

**Rules for the whole game:**

- **Textures:** 4 shared grayscale textures at 256 px (soft circle, streak, zigzag, sparkle), tinted per use (vault technique 6), plus at most 1 flipbook (an optional splash). That is within the vault's 2-4.
- **Distant fronts:** each front away from the camera is one cloud-cell mesh over its spot, plus one rain-curtain Beam with a scrolling streak texture for Showers. With at most 3 fronts that is 6 objects. There are no weather particles beyond 80 studs.
- **Self first:** other players' catch effects play at the lower tier (vault technique 5).
- **Code rules:** every effect is client-side and pooled, bursts use `Emit()`, and nothing calls `Instance.new` per catch (vault "warning signs in code review"). Emitters and Beams live on plain parts or attachments, never inside unions.
- **Measure:** run the vault stress test (lines 67-73) on the worst case: a Great Storm with 12 players at the pier, a Charged landing with confetti, and 11 Pull threads. Effect time in the MicroProfiler must stay under 2 ms on the low-end profile.

## 12. Feedback scale by rarity (juice)

Rarer outcomes get bigger, longer and louder feedback. Loudness grows through layering and swells, never a sudden spike (cozy rule "calm audio"). Particles come out of the 120 reward budget above.

| Outcome | Visual | Duration | Sound |
|---|---|---|---|
| Common | Splash `Emit(6)`, coin pop to the counter | 0.6 s | Soft plink |
| Uncommon | Adds a ring ripple in the rarity colour | 0.8 s | Adds a second note |
| Rare | Adds a short rarity beam (8 studs) and sparkles `Emit(12)` | 1.0 s | Rising chime |
| Epic | Adds rotating rays behind the catch card | 1.4 s | Chime with a soft chord |
| Legendary | Adds a 40-stud rarity beacon (vfx-recipes, recipe 23) and a server banner | 2.0 s | A short music phrase that swells in |
| Mythic, Secret and every Stormborn | Adds 0.4 s of slow motion at the top of the leap, gold confetti `Emit(60)`, and a banner naming every helper | 3.0 s | The full phrase with a crowd cheer |
| Any weather mark | The mark's shape stamps onto the card | Adds 0.3 s | A tone for that mark |

## 13. Notes for other roles

- **Interface Designer:** keep the template's fonts (`FredokaOne` display, `BuilderSansBold` body), `Theme.corner` 14 and touch target 56. Retint the theme to backdrop Night Ink `#18203A`, panel Storm Slate `#2E3F5C`, panel light `#3E5376` and text Shell Cream `#FFF8EC`, and keep the accent at Lantern Gold. Do not use `bad` red for fishing feedback.
- **Assets and IP:** no asset was made, inserted or uploaded in this task, so the asset index gets no entries yet. Every name here comes from the loop sketch or is newly invented. `FredokaOne` and `BuilderSans` are Roblox's built-in `Enum.Font` faces. Any future tool that charges money or credits is a money escalation (house rule 2).

## 14. Open questions

1. **Day-night cycle (Designer).** Does the game have a time-of-day cycle besides Aurora Night? Section 6 fixes ClockTime per weather. A cycle would need a second set of night presets for Clear, Showers, Sea Fog and Gusts.
2. **The Charged cue under Reduce Motion (Designer, Interface Designer).** The lightning flash is both the tap cue for a Charged catch and a comfort risk. Section 7 replaces it with a steady gold glow on the line when Reduce Motion is on. Confirm that the tap window still reads without the flash, and test it in the prototype.
3. **A "Reduce effects" setting (Engineer).** The template's settings panel has `reduceMotion` but no effects toggle, while the vault asks for a "reduce effects" option honoured everywhere (`vfx-performance-budgets.md`, technique 10). Should the low-quality tier in section 11 follow the device's graphics quality only, or also a player setting?

Related: [Loop sketch](loop-sketch.md) · [Pitch](pitch.md) · [Market scan](market-scan.md) · [Decisions](decisions.md) · [Art direction (vault)](../../../vault/06-world-and-look/art-direction.md) · [VFX performance budgets (vault)](../../../vault/19-vfx/vfx-performance-budgets.md)
