// The Ascent look for every ECharts chart, read from the brand color tokens so a palette change in
// tailwind/variables/colors.css reaches the charts too. Summit leads the series colors: a bar or mark
// in lime is an approval. Parties are never colors, so the rest of the palette is rope and stone.
export const themeName = "ascent"

function token(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(`--brand-${name}`).trim()
}

function axis(color) {
  return {
    axisLine: { lineStyle: { color: token("mist") } },
    axisTick: { show: false },
    axisLabel: { color },
    splitLine: { lineStyle: { color: token("contour") } }
  }
}

// Charts take the font of the element they draw in, so they read like the card around them.
export function ascentTheme(element) {
  const font = getComputedStyle(element).fontFamily

  return {
    color: [ token("summit"), token("rope"), token("slate"), token("pebble"), token("scree") ],
    backgroundColor: "transparent",
    textStyle: { fontFamily: font, color: token("basalt") },
    title: { textStyle: { color: token("basalt") }, subtextStyle: { color: token("moss") } },
    legend: { textStyle: { color: token("slate") } },
    tooltip: {
      backgroundColor: token("basalt"),
      borderWidth: 0,
      textStyle: { color: token("snow"), fontFamily: font }
    },
    categoryAxis: axis(token("basalt")),
    valueAxis: axis(token("moss")),
    bar: { itemStyle: { borderRadius: [ 0, 6, 6, 0 ] } },
    line: { symbolSize: 8, lineStyle: { width: 3 } },
    visualMap: { inRange: { color: [ token("lichen"), token("summit-wash"), token("summit"), token("summit-deep") ] } }
  }
}
