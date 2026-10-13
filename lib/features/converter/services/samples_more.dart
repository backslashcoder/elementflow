/// Ten additional full-page samples (see `samples.dart`).
library;

const portfolioSample = r'''<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><title>Nora Vance — Designer</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; font-family: Helvetica, Arial, sans-serif; background: #111; color: #eee; }
  .top { display: flex; justify-content: space-between; align-items: center; padding: 20px 28px; }
  .logo { font-weight: bold; letter-spacing: 3px; font-size: 14px; }
  .links a { color: #aaa; margin-left: 18px; font-size: 13px; text-decoration: none; }
  .intro { padding: 48px 28px 32px; }
  .intro small { color: #ff5a5f; letter-spacing: 2px; font-size: 12px; }
  .intro h1 { font-size: 40px; line-height: 1.1; margin: 12px 0; }
  .intro p { color: #9a9a9a; line-height: 1.6; max-width: 520px; }
  .work { display: flex; flex-wrap: wrap; gap: 16px; padding: 8px 28px 32px; }
  .piece { width: 220px; background: #1c1c1c; border-radius: 12px; overflow: hidden; }
  .piece img { width: 100%; height: 130px; object-fit: cover; }
  .piece div { padding: 12px 14px; }
  .piece b { display: block; font-size: 15px; }
  .piece span { font-size: 12px; color: #888; }
  .skills { padding: 0 28px 32px; }
  .tag { display: inline-block; background: #262626; color: #ddd; padding: 6px 14px; border-radius: 16px; font-size: 13px; margin: 0 8px 8px 0; }
  .contact { margin: 0 28px 28px; padding: 24px; border-radius: 16px; background: linear-gradient(120deg, #ff5a5f, #ff9a5a); color: #fff; }
  .contact h2 { margin: 0 0 6px; }
  footer { text-align: center; color: #666; font-size: 12px; padding: 20px; }
</style></head>
<body>
  <div class="top"><span class="logo">NORA VANCE</span>
    <span class="links"><a href="#">Work</a><a href="#">About</a><a href="#">Contact</a></span></div>
  <div class="intro"><small>PRODUCT DESIGNER</small>
    <h1>I design calm, useful interfaces.</h1>
    <p>Ten years shaping apps for health, finance and education. Currently open to select freelance projects.</p></div>
  <div class="work">
    <div class="piece"><img src="https://picsum.photos/id/1015/440/260" alt=""><div><b>Pulse</b><span>Health tracking app</span></div></div>
    <div class="piece"><img src="https://picsum.photos/id/1043/440/260" alt=""><div><b>Ledger</b><span>Personal finance</span></div></div>
    <div class="piece"><img src="https://picsum.photos/id/1067/440/260" alt=""><div><b>Atlas</b><span>Learning platform</span></div></div>
  </div>
  <div class="skills"><h3>Skills</h3>
    <span class="tag">UX research</span><span class="tag">Prototyping</span><span class="tag">Design systems</span><span class="tag">Motion</span><span class="tag">Accessibility</span></div>
  <div class="contact"><h2>Let's work together</h2><p style="margin:0">hello@noravance.design</p></div>
  <footer>© 2026 Nora Vance</footer>
</body></html>''';

const saasSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Flowboard</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; font-family: Arial, sans-serif; color: #1f2937; background: #fff; }
  nav { display: flex; justify-content: space-between; align-items: center; padding: 16px 32px; border-bottom: 1px solid #eef0f4; }
  nav b { font-size: 20px; color: #4f46e5; }
  nav a { color: #4b5563; margin-left: 20px; font-size: 14px; }
  .hero { text-align: center; padding: 64px 24px 48px; background: linear-gradient(180deg, #eef2ff 0%, #ffffff 100%); }
  .hero h1 { font-size: 40px; margin: 0 auto 12px; max-width: 560px; line-height: 1.15; }
  .hero p { color: #6b7280; font-size: 17px; max-width: 480px; margin: 0 auto 24px; line-height: 1.5; }
  .cta { background: #4f46e5; color: #fff; border: 0; padding: 14px 28px; border-radius: 10px; font-size: 16px; }
  .ghost { background: #fff; color: #4f46e5; border: 1px solid #c7d2fe; padding: 13px 24px; border-radius: 10px; font-size: 16px; margin-left: 10px; }
  .features { display: flex; gap: 20px; padding: 32px; }
  .f { flex: 1; padding: 20px; border: 1px solid #eef0f4; border-radius: 14px; }
  .f .ic { width: 40px; height: 40px; border-radius: 10px; background: #e0e7ff; margin-bottom: 12px; }
  .f h3 { margin: 0 0 6px; font-size: 17px; }
  .f p { margin: 0; color: #6b7280; font-size: 14px; line-height: 1.5; }
  .quote { margin: 0 32px 32px; padding: 28px; background: #1e1b4b; color: #e0e7ff; border-radius: 16px; }
  .quote p { font-size: 20px; line-height: 1.5; margin: 0 0 12px; }
  .quote span { font-size: 13px; color: #a5b4fc; }
  .final { text-align: center; padding: 32px 24px 48px; }
  footer { background: #f9fafb; padding: 20px 32px; font-size: 13px; color: #6b7280; display: flex; justify-content: space-between; }
</style></head>
<body>
  <nav><b>Flowboard</b><span><a href="#">Product</a><a href="#">Pricing</a><a href="#">Docs</a></span></nav>
  <section class="hero"><h1>Plan work the way your team actually thinks</h1>
    <p>Boards, timelines and docs in one calm workspace. Free for small teams.</p>
    <button class="cta">Start free</button><button class="ghost">Watch demo</button></section>
  <section class="features">
    <div class="f"><div class="ic"></div><h3>Boards</h3><p>Drag cards across stages and keep context attached.</p></div>
    <div class="f"><div class="ic"></div><h3>Timelines</h3><p>See dependencies and slipping dates at a glance.</p></div>
    <div class="f"><div class="ic"></div><h3>Docs</h3><p>Write specs next to the work they describe.</p></div>
  </section>
  <section class="quote"><p>“We replaced three tools with Flowboard in a week.”</p><span>Maya Chen, Head of Product at Lumio</span></section>
  <section class="final"><h2>Ready when you are</h2><button class="cta">Create your workspace</button></section>
  <footer><span>© 2026 Flowboard Inc.</span><span>Privacy · Terms</span></footer>
</body></html>''';

const newsletterSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Weekly Digest</title>
<style>
  body { margin: 0; background: #e9ecef; font-family: Georgia, serif; }
  .wrap { max-width: 560px; margin: 0 auto; background: #fff; }
  .head { background: #0b3d91; color: #fff; text-align: center; padding: 28px 20px; }
  .head h1 { margin: 0; font-size: 26px; letter-spacing: 1px; }
  .head p { margin: 6px 0 0; font-size: 13px; color: #bcd0f5; font-family: Arial, sans-serif; }
  .body { padding: 24px; color: #333; line-height: 1.6; }
  .body h2 { color: #0b3d91; font-size: 20px; margin: 0 0 6px; }
  .story { padding-bottom: 16px; border-bottom: 1px solid #e5e5e5; margin-bottom: 16px; }
  .story img { width: 100%; height: 150px; object-fit: cover; border-radius: 6px; margin-bottom: 10px; }
  .btn { display: inline-block; background: #e8590c; color: #fff; padding: 10px 20px; border-radius: 4px; font-family: Arial, sans-serif; font-size: 14px; }
  .links { background: #f1f3f5; padding: 16px 24px; font-family: Arial, sans-serif; font-size: 13px; }
  .links li { margin-bottom: 6px; }
  .foot { text-align: center; font-size: 12px; color: #868e96; padding: 18px; font-family: Arial, sans-serif; }
</style></head>
<body><div class="wrap">
  <div class="head"><h1>THE WEEKLY DIGEST</h1><p>Issue 42 · Tuesday 13 October</p></div>
  <div class="body">
    <div class="story"><img src="https://picsum.photos/id/1011/700/300" alt="">
      <h2>The quiet return of train travel</h2>
      <p>Night trains are back across Europe, and ticket sales have doubled. We rode three routes to see what changed.</p>
      <span class="btn">Read the story</span></div>
    <div class="story"><h2>Five spreadsheets worth stealing</h2>
      <p>From budgeting to meal planning, the templates readers swear by.</p></div>
    <p><em>Enjoying this? Forward it to a friend.</em></p>
  </div>
  <div class="links"><b>Also this week</b>
    <ul><li>Why bread prices keep rising</li><li>A beginner's guide to birdsong</li><li>Reader mailbag</li></ul></div>
  <div class="foot">You are receiving this because you subscribed.<br>Unsubscribe · Preferences</div>
</div></body></html>''';

const recipeSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Lemon Pasta</title>
<style>
  body { margin: 0; font-family: Georgia, serif; background: #fdf8f0; color: #3b2f2f; }
  .page { max-width: 620px; margin: 0 auto; padding: 24px; }
  h1 { font-size: 34px; margin: 0 0 6px; }
  .meta { display: flex; gap: 12px; margin: 14px 0 20px; font-family: Arial, sans-serif; font-size: 13px; }
  .meta div { background: #fff; border: 1px solid #eadfcc; border-radius: 10px; padding: 10px 14px; text-align: center; flex: 1; }
  .meta b { display: block; font-size: 18px; color: #c2410c; }
  .hero { width: 100%; height: 210px; object-fit: cover; border-radius: 14px; }
  h2 { font-size: 22px; border-bottom: 2px solid #c2410c; padding-bottom: 4px; margin-top: 28px; }
  li { margin-bottom: 8px; line-height: 1.5; }
  .tip { background: #fff3d6; border-left: 5px solid #f59e0b; padding: 12px 16px; border-radius: 6px; font-family: Arial, sans-serif; font-size: 14px; }
  table { width: 100%; border-collapse: collapse; font-family: Arial, sans-serif; font-size: 14px; }
  td, th { border-bottom: 1px solid #eadfcc; padding: 8px; text-align: left; }
</style></head>
<body><div class="page">
  <h1>Bright Lemon Pasta</h1><p style="color:#7c6f64;margin:0">Ready in 20 minutes · serves 4</p>
  <img class="hero" src="https://picsum.photos/id/292/900/400" alt="Pasta">
  <div class="meta"><div><b>20</b>minutes</div><div><b>4</b>servings</div><div><b>Easy</b>level</div></div>
  <h2>Ingredients</h2>
  <ul><li>400 g spaghetti</li><li>2 lemons, zest and juice</li><li>60 g butter</li><li>50 g grated parmesan</li><li>Black pepper and salt</li></ul>
  <h2>Method</h2>
  <ol><li>Boil the pasta in well-salted water until just al dente.</li>
    <li>Melt the butter, add lemon zest and a splash of pasta water.</li>
    <li>Toss everything with the lemon juice and parmesan until glossy.</li></ol>
  <p class="tip"><b>Tip:</b> save a cup of pasta water. The starch makes the sauce silky.</p>
  <h2>Nutrition per serving</h2>
  <table><tr><th>Calories</th><th>Protein</th><th>Carbs</th></tr><tr><td>520</td><td>18 g</td><td>72 g</td></tr></table>
</div></body></html>''';

const travelSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Lisbon</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; font-family: Arial, sans-serif; color: #12263a; background: #f4f8fb; }
  .cover { height: 260px; background: linear-gradient(0deg, rgba(10,30,60,.75), rgba(10,30,60,.1)), #2b6cb0; color: #fff; padding: 24px; display: flex; flex-direction: column; justify-content: flex-end; }
  .cover h1 { margin: 0; font-size: 38px; }
  .cover p { margin: 4px 0 0; color: #cfe3f7; }
  .bar { display: flex; justify-content: space-around; background: #fff; padding: 14px; box-shadow: 0 2px 8px rgba(0,0,0,.08); font-size: 13px; }
  .bar b { display: block; font-size: 16px; color: #2b6cb0; }
  .sec { padding: 22px 24px 4px; }
  .sec h2 { margin: 0 0 10px; font-size: 20px; }
  .stop { display: flex; gap: 14px; background: #fff; border-radius: 12px; padding: 12px; margin-bottom: 12px; }
  .stop img { width: 84px; height: 84px; border-radius: 10px; object-fit: cover; }
  .stop h3 { margin: 0 0 4px; font-size: 16px; }
  .stop p { margin: 0; font-size: 13px; color: #5b6f82; line-height: 1.45; }
  .badge { display: inline-block; background: #e6fffa; color: #0f766e; font-size: 11px; padding: 3px 8px; border-radius: 10px; margin-top: 6px; }
  .book { margin: 8px 24px 28px; padding: 18px; background: #12263a; color: #fff; border-radius: 14px; display: flex; justify-content: space-between; align-items: center; }
  .book button { background: #f6ad55; border: 0; padding: 10px 18px; border-radius: 8px; font-weight: bold; }
</style></head>
<body>
  <div class="cover"><h1>Lisbon</h1><p>Three days of tiles, trams and custard tarts</p></div>
  <div class="bar"><div><b>3</b>days</div><div><b>18°C</b>weather</div><div><b>€€</b>budget</div></div>
  <div class="sec"><h2>Itinerary</h2>
    <div class="stop"><img src="https://picsum.photos/id/1040/200/200" alt=""><div><h3>Day 1 · Alfama</h3><p>Wander the old quarter, ride tram 28 and watch sunset from Portas do Sol.</p><span class="badge">Walking</span></div></div>
    <div class="stop"><img src="https://picsum.photos/id/1039/200/200" alt=""><div><h3>Day 2 · Belém</h3><p>Monastery, tower and the famous pastry shop by the river.</p><span class="badge">Culture</span></div></div>
    <div class="stop"><img src="https://picsum.photos/id/1018/200/200" alt=""><div><h3>Day 3 · Sintra</h3><p>A fairytale palace and forest trails a short train ride away.</p><span class="badge">Day trip</span></div></div>
  </div>
  <div class="book"><div><b>From €240</b><br><small>flights + 2 nights</small></div><button>Book trip</button></div>
</body></html>''';

const fitnessSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>FitWeek</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; background: #0f172a; color: #e2e8f0; font-family: Arial, sans-serif; padding: 20px; }
  h1 { font-size: 24px; margin: 0; }
  .sub { color: #94a3b8; font-size: 14px; margin: 4px 0 18px; }
  .ring { display: flex; gap: 12px; margin-bottom: 18px; }
  .stat { flex: 1; background: #1e293b; border-radius: 16px; padding: 14px; text-align: center; }
  .stat b { display: block; font-size: 26px; color: #38bdf8; }
  .stat span { font-size: 12px; color: #94a3b8; }
  .card { background: #1e293b; border-radius: 16px; padding: 16px; margin-bottom: 14px; }
  .row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #334155; }
  .row:last-child { border-bottom: 0; }
  .row b { font-size: 15px; }
  .row small { color: #94a3b8; }
  .done { color: #4ade80; font-size: 13px; }
  .todo { color: #fbbf24; font-size: 13px; }
  .bar { height: 10px; background: #334155; border-radius: 5px; }
  .fill { height: 10px; width: 68%; background: linear-gradient(90deg, #38bdf8, #4ade80); border-radius: 5px; }
  .go { width: 100%; padding: 14px; border: 0; border-radius: 14px; background: #38bdf8; color: #0f172a; font-weight: bold; font-size: 16px; }
</style></head>
<body>
  <h1>Good morning, Sam</h1><p class="sub">Week 3 · Strength block</p>
  <div class="ring"><div class="stat"><b>4</b><span>workouts</span></div><div class="stat"><b>1.2k</b><span>kcal</span></div><div class="stat"><b>6h</b><span>active</span></div></div>
  <div class="card"><b>Weekly goal</b><p class="sub" style="margin:4px 0 10px">68% complete</p><div class="bar"><div class="fill"></div></div></div>
  <div class="card"><b>Today's plan</b>
    <div class="row"><div><b>Back squat</b><br><small>4 × 8 · 60 kg</small></div><span class="done">Done</span></div>
    <div class="row"><div><b>Bench press</b><br><small>4 × 8 · 45 kg</small></div><span class="done">Done</span></div>
    <div class="row"><div><b>Pull-ups</b><br><small>3 × 10</small></div><span class="todo">Next</span></div>
    <div class="row"><div><b>Plank</b><br><small>3 × 60 s</small></div><span class="todo">Next</span></div></div>
  <button class="go">Resume workout</button>
</body></html>''';

const docsSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Docs</title>
<style>
  body { margin: 0; font-family: Arial, sans-serif; color: #24292f; }
  .top { background: #24292f; color: #fff; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
  .top input { width: 220px; background: #3b4148; border: 0; border-radius: 6px; padding: 8px 10px; color: #fff; }
  .layout { display: flex; }
  .side { width: 180px; background: #f6f8fa; padding: 18px; border-right: 1px solid #d0d7de; font-size: 14px; }
  .side b { display: block; margin: 10px 0 6px; font-size: 12px; color: #57606a; letter-spacing: 1px; }
  .side div { padding: 5px 0; color: #0969da; }
  .main { flex: 1; padding: 24px 28px; }
  h1 { font-size: 30px; border-bottom: 1px solid #d0d7de; padding-bottom: 8px; margin-top: 0; }
  code { background: #eff1f3; padding: 2px 6px; border-radius: 4px; font-family: monospace; font-size: 13px; }
  pre { background: #0d1117; color: #c9d1d9; padding: 14px; border-radius: 8px; font-size: 13px; }
  .note { background: #ddf4ff; border: 1px solid #54aeff; border-radius: 8px; padding: 12px 14px; font-size: 14px; }
  .warn { background: #fff8c5; border: 1px solid #d4a72c; border-radius: 8px; padding: 12px 14px; font-size: 14px; margin-top: 12px; }
  h2 { font-size: 22px; margin-top: 28px; }
  details { margin: 8px 0; }
</style></head>
<body>
  <div class="top"><b>Acme Docs</b><input type="text" placeholder="Search the docs"></div>
  <div class="layout">
    <div class="side"><b>START</b><div>Overview</div><div>Installation</div><div>Quick start</div><b>GUIDES</b><div>Authentication</div><div>Webhooks</div><div>Errors</div></div>
    <div class="main">
      <h1>Quick start</h1>
      <p>Install the client and make your first request in under a minute.</p>
      <pre>npm install acme-client
acme login --token $TOKEN</pre>
      <p class="note"><b>Note:</b> tokens expire after 30 days. Use <code>acme refresh</code> to renew.</p>
      <h2>Configuration</h2>
      <ul><li><code>timeout</code> request timeout in milliseconds</li><li><code>retries</code> number of automatic retries</li><li><code>region</code> data residency region</li></ul>
      <p class="warn"><b>Heads up:</b> the <code>region</code> option cannot be changed after the first request.</p>
    </div>
  </div>
</body></html>''';

const realEstateSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Listing</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; font-family: Arial, sans-serif; color: #222; background: #f7f7f7; }
  .photo { width: 100%; height: 230px; object-fit: cover; }
  .main { background: #fff; padding: 20px 24px; }
  .price { font-size: 30px; font-weight: bold; color: #0a7f5a; }
  .addr { color: #666; margin: 4px 0 14px; }
  .facts { display: flex; gap: 10px; }
  .facts div { flex: 1; background: #f3f6f4; border-radius: 10px; padding: 10px; text-align: center; font-size: 13px; color: #555; }
  .facts b { display: block; font-size: 18px; color: #222; }
  .tag { display: inline-block; font-size: 12px; background: #e8f5ee; color: #0a7f5a; padding: 4px 10px; border-radius: 12px; margin: 14px 6px 0 0; }
  .desc { background: #fff; margin-top: 10px; padding: 18px 24px; line-height: 1.6; font-size: 15px; }
  .agent { background: #fff; margin-top: 10px; padding: 18px 24px; display: flex; align-items: center; gap: 14px; }
  .agent img { width: 56px; height: 56px; border-radius: 28px; object-fit: cover; }
  .agent button { margin-left: auto; background: #0a7f5a; color: #fff; border: 0; padding: 10px 18px; border-radius: 8px; }
  table { width: 100%; border-collapse: collapse; font-size: 14px; }
  td { padding: 8px 0; border-bottom: 1px solid #eee; }
</style></head>
<body>
  <img class="photo" src="https://picsum.photos/id/1068/900/460" alt="House">
  <div class="main"><div class="price">$485,000</div><div class="addr">24 Maple Court, Brookfield</div>
    <div class="facts"><div><b>3</b>beds</div><div><b>2</b>baths</div><div><b>1,640</b>sq ft</div></div>
    <span class="tag">Garden</span><span class="tag">Garage</span><span class="tag">Renovated</span></div>
  <div class="desc"><b>About this home</b><p>Sun-filled family house with an open kitchen, a south-facing garden and a quiet street close to schools and the park.</p>
    <table><tr><td>Year built</td><td style="text-align:right">1998</td></tr><tr><td>Heating</td><td style="text-align:right">Gas central</td></tr><tr><td>Parking</td><td style="text-align:right">2 spaces</td></tr></table></div>
  <div class="agent"><img src="https://picsum.photos/id/338/120/120" alt=""><div><b>Elena Ruiz</b><br><small>Brookfield Realty</small></div><button>Contact</button></div>
</body></html>''';

const musicSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Now playing</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; font-family: Arial, sans-serif; color: #fff; background: linear-gradient(180deg, #4c1d95 0%, #111827 60%); padding: 24px; }
  .cover { display: block; width: 240px; height: 240px; margin: 12px auto 20px; border-radius: 18px; object-fit: cover; box-shadow: 0 16px 40px rgba(0,0,0,.5); }
  h1 { text-align: center; font-size: 24px; margin: 0; }
  .artist { text-align: center; color: #c4b5fd; margin: 6px 0 18px; }
  .time { display: flex; justify-content: space-between; font-size: 12px; color: #c4b5fd; }
  .controls { display: flex; justify-content: center; gap: 28px; align-items: center; margin: 14px 0 24px; }
  .circle { width: 64px; height: 64px; border-radius: 32px; background: #fff; color: #4c1d95; text-align: center; font-size: 26px; line-height: 64px; }
  .small { font-size: 22px; color: #ddd6fe; }
  .queue { background: rgba(255,255,255,.08); border-radius: 16px; padding: 8px 16px; }
  .song { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,.1); font-size: 14px; }
  .song:last-child { border-bottom: 0; }
  .song small { color: #c4b5fd; }
</style></head>
<body>
  <img class="cover" src="https://picsum.photos/id/1025/500/500" alt="">
  <h1>Midnight Drive</h1><p class="artist">The Neon Coast</p>
  <input type="range" value="40" style="width:100%">
  <div class="time"><span>1:36</span><span>3:58</span></div>
  <div class="controls"><span class="small">⏮</span><span class="circle">▶</span><span class="small">⏭</span></div>
  <div class="queue"><b>Up next</b>
    <div class="song"><span>Glass Harbor<br><small>The Neon Coast</small></span><small>3:12</small></div>
    <div class="song"><span>Afterglow<br><small>Luma</small></span><small>4:05</small></div>
    <div class="song"><span>City Lights<br><small>Kite &amp; Co</small></span><small>2:48</small></div></div>
</body></html>''';

const resumeSample = r'''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Resume</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; background: #e5e7eb; font-family: Georgia, serif; color: #1f2937; padding: 20px; }
  .sheet { max-width: 680px; margin: 0 auto; background: #fff; padding: 36px; box-shadow: 0 4px 16px rgba(0,0,0,.12); }
  .head { display: flex; justify-content: space-between; align-items: flex-end; border-bottom: 3px solid #1f2937; padding-bottom: 12px; }
  .head h1 { margin: 0; font-size: 32px; letter-spacing: 1px; }
  .head span { font-family: Arial, sans-serif; font-size: 13px; color: #4b5563; text-align: right; line-height: 1.5; }
  h2 { font-family: Arial, sans-serif; font-size: 13px; letter-spacing: 2px; color: #6b7280; margin: 24px 0 8px; }
  .job { margin-bottom: 14px; }
  .job .t { display: flex; justify-content: space-between; }
  .job b { font-size: 16px; }
  .job i { color: #6b7280; font-size: 14px; }
  .job ul { margin: 6px 0 0; padding-left: 20px; font-size: 14px; line-height: 1.6; }
  .skills span { display: inline-block; border: 1px solid #9ca3af; border-radius: 4px; padding: 3px 10px; margin: 0 6px 6px 0; font-family: Arial, sans-serif; font-size: 12px; }
  table { width: 100%; font-size: 14px; border-collapse: collapse; }
  td { padding: 4px 0; }
</style></head>
<body><div class="sheet">
  <div class="head"><h1>ARJUN MEHTA</h1><span>Software Engineer<br>arjun@example.com · Pune, India</span></div>
  <h2>EXPERIENCE</h2>
  <div class="job"><div class="t"><b>Senior Engineer, Northwind</b><i>2022 – Present</i></div>
    <ul><li>Led migration of a payments service to a modular architecture.</li><li>Cut p95 latency by 40% through caching and query tuning.</li><li>Mentored four engineers.</li></ul></div>
  <div class="job"><div class="t"><b>Engineer, Contoso Labs</b><i>2018 – 2022</i></div>
    <ul><li>Built a mobile app used by 200k people.</li><li>Introduced automated testing and CI.</li></ul></div>
  <h2>SKILLS</h2>
  <div class="skills"><span>Dart</span><span>Flutter</span><span>Go</span><span>PostgreSQL</span><span>Kubernetes</span><span>System design</span></div>
  <h2>EDUCATION</h2>
  <table><tr><td><b>B.Tech, Computer Science</b></td><td style="text-align:right">2014 – 2018</td></tr><tr><td>College of Engineering Pune</td><td></td></tr></table>
</div></body></html>''';
