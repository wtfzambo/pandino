# Anti-patterns

Never ship these. Each one is decoration without a job, or a claim without a source. A pattern the project's design system or the user's brief asks for by name is exempt.

## Color

- Purple or indigo gradients, and cyan glow on a dark background.
- Gradient-filled text.
- More than one accent color without a meaning for each.
- Neutral gray text over a tinted or colored fill. Derive the text color from the fill's own hue.

## Typography

- A small uppercase label above a heading.
- Numbered section labels (01, 02, 03) where the order carries no information.
- Uppercase or wide letter spacing on sentences. Keep both for short labels.
- Justified text in a narrow column.
- Monospace type on text that is neither code nor data.

## Layout

- Everything centered.
- A hero followed by three feature cards as the default page.
- A card inside a card.
- A grid of identical cards, each an icon, a heading, and a sentence.
- A large number with a small label as the opening of a page that is not a dashboard.
- A dialog where the same step would fit inline.

## Surfaces

- Glass, blur, or glow with no function.
- A colored halo behind a section, or decorative blobs in the background.
- Stripes or grid lines in the background of a surface that is not a canvas, map, or ruler.
- A large uniform radius with a soft shadow on every element.
- A hairline border and a wide shadow on the same card. Choose an edge or an elevation.
- A rounded box with a thick colored stripe along a single edge.

## Icons and images

- Emoji as icons.
- An icon on every heading or list item.
- An icon in a rounded tile above each card heading.
- A hero illustration assembled from simple shapes.
- An image with an empty or placeholder source.

## Motion

- Entrance or scroll-in animation on static content.
- Auto-scrolling content such as a marquee.
- A pulsing dot on data that is not live.
- A blinking cursor where nothing can be typed.
- Bounce or elastic easing.

## Invented content

- Metrics, testimonials, customer logos, or "New" badges the user did not supply.
- Marketing words that name no function: streamline, empower, supercharge, next-generation.
- The same text repeated in several places in one card or panel.
