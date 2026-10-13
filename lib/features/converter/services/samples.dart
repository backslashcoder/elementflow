import 'sample_html.dart';
import 'samples_more.dart';

/// A demonstration page offered in the "Samples" menu.
class HtmlSample {
  const HtmlSample(this.name, this.description, this.html);
  final String name;
  final String description;
  final String html;
}

final htmlSamples = <HtmlSample>[
  const HtmlSample(
    'Coffee shop landing page',
    'Header, gradient hero, cards, list, table and form',
    landingPageSample,
  ),
  const HtmlSample(
    'Profile card',
    'Centered card with avatar, shadow and button',
    _profile,
  ),
  const HtmlSample(
    'Pricing plans',
    'Side-by-side plan cards with highlights',
    _pricing,
  ),
  const HtmlSample(
    'Sign-up form',
    'Inputs, checkbox and submit button',
    _signup,
  ),
  const HtmlSample(
    'Blog article',
    'Typography, quote, list and inline styles',
    _blog,
  ),
  const HtmlSample(
    'Dashboard',
    'Stat cards, badges and a data table',
    _dashboard,
  ),
  const HtmlSample(
    'Product grid',
    'Wrapping grid of product cards with prices',
    _products,
  ),
  const HtmlSample(
    'Login screen',
    'Gradient background with a centered form',
    _login,
  ),
  const HtmlSample(
    'Event ticket',
    'Gradient ticket with rows and a divider',
    _ticket,
  ),
  const HtmlSample(
    'Restaurant menu',
    'Sections, dotted-style rows and dividers',
    _menu,
  ),
  const HtmlSample(
    'Designer portfolio',
    'Dark page with project cards, tags and gradient contact box',
    portfolioSample,
  ),
  const HtmlSample(
    'SaaS landing page',
    'Nav, hero, feature cards, testimonial and footer',
    saasSample,
  ),
  const HtmlSample(
    'Email newsletter',
    'Narrow email layout with stories and link list',
    newsletterSample,
  ),
  const HtmlSample(
    'Recipe page',
    'Stat boxes, ingredients, steps, tip callout and table',
    recipeSample,
  ),
  const HtmlSample(
    'Travel itinerary',
    'Cover, quick facts, stop cards and booking bar',
    travelSample,
  ),
  const HtmlSample(
    'Fitness tracker',
    'Dark app screen with stats, progress bar and workout list',
    fitnessSample,
  ),
  const HtmlSample(
    'Documentation page',
    'Sidebar layout with code block, callouts and search box',
    docsSample,
  ),
  const HtmlSample(
    'Real estate listing',
    'Photo, price, facts, description and agent card',
    realEstateSample,
  ),
  const HtmlSample(
    'Music player',
    'Gradient now-playing screen with slider and queue',
    musicSample,
  ),
  const HtmlSample(
    'Resume',
    'Printable-style resume sheet with experience and skills',
    resumeSample,
  ),
];

const _profile = r'''
<div style="max-width:320px;margin:24px auto;padding:20px;background:#ffffff;
            border:1px solid #e0e0e0;border-radius:16px;text-align:center;
            box-shadow:0 4px 12px rgba(0,0,0,.1);font-family:Arial,sans-serif">
  <img src="https://picsum.photos/id/64/200/200" alt="Avatar" width="96" height="96"
       style="border-radius:48px;object-fit:cover">
  <h2 style="margin:12px 0 4px">Ada Lovelace</h2>
  <p style="margin:0;color:#757575">Mathematician &amp; writer</p>
  <p style="margin:12px 0;font-size:14px;line-height:1.5;color:#424242">
    Wrote the first published algorithm intended for a machine.
  </p>
  <button style="margin-top:8px;background:#3f51b5;color:#fff;border:0;
                 padding:10px 24px;border-radius:8px;font-size:15px">Follow</button>
</div>''';

const _pricing = r'''
<div style="font-family:Arial,sans-serif;background:#f5f5f5;padding:24px">
  <h1 style="text-align:center;margin:0 0 4px">Simple pricing</h1>
  <p style="text-align:center;color:#616161;margin:0 0 24px">Pick a plan that grows with you.</p>
  <div style="display:flex;gap:16px">
    <div style="flex:1;background:#fff;padding:20px;border-radius:12px;border:1px solid #e0e0e0">
      <h3 style="margin:0;color:#424242">Free</h3>
      <p style="font-size:32px;font-weight:bold;margin:8px 0">$0</p>
      <ul style="padding-left:20px;line-height:1.8;color:#616161">
        <li>1 project</li><li>Community support</li>
      </ul>
    </div>
    <div style="flex:1;background:#3f51b5;color:#fff;padding:20px;border-radius:12px;
                box-shadow:0 8px 20px rgba(63,81,181,.4)">
      <h3 style="margin:0">Pro</h3>
      <p style="font-size:32px;font-weight:bold;margin:8px 0">$12</p>
      <ul style="padding-left:20px;line-height:1.8">
        <li>Unlimited projects</li><li>Priority support</li>
      </ul>
      <button style="width:100%;padding:10px;border:0;border-radius:8px;background:#fff;color:#3f51b5;font-weight:bold">Get Pro</button>
    </div>
    <div style="flex:1;background:#fff;padding:20px;border-radius:12px;border:1px solid #e0e0e0">
      <h3 style="margin:0;color:#424242">Team</h3>
      <p style="font-size:32px;font-weight:bold;margin:8px 0">$49</p>
      <ul style="padding-left:20px;line-height:1.8;color:#616161">
        <li>10 seats</li><li>SSO &amp; audit log</li>
      </ul>
    </div>
  </div>
</div>''';

const _signup = r'''
<form style="max-width:420px;margin:0 auto;padding:24px;font-family:Arial,sans-serif">
  <h1 style="font-size:26px;margin-bottom:4px">Create your account</h1>
  <p style="color:#757575;margin-top:0">It only takes a minute.</p>
  <label style="display:block;font-size:13px;margin:12px 0 4px">Full name</label>
  <input type="text" placeholder="Jane Doe" style="width:100%;padding:10px;border:1px solid #bdbdbd;border-radius:6px">
  <label style="display:block;font-size:13px;margin:12px 0 4px">Email</label>
  <input type="email" placeholder="jane@example.com" style="width:100%;padding:10px;border:1px solid #bdbdbd;border-radius:6px">
  <label style="display:block;font-size:13px;margin:12px 0 4px">Password</label>
  <input type="password" placeholder="At least 8 characters" style="width:100%;padding:10px;border:1px solid #bdbdbd;border-radius:6px">
  <label style="display:block;font-size:13px;margin:12px 0 4px">Country</label>
  <select style="width:100%;padding:10px;border:1px solid #bdbdbd;border-radius:6px;background:#fff">
    <option>India</option><option>Germany</option>
  </select>
  <p style="font-size:14px"><input type="checkbox" checked> I agree to the terms</p>
  <button type="submit" style="width:100%;padding:12px;border:0;border-radius:8px;background:#00897b;color:#fff;font-size:16px">Create account</button>
</form>''';

const _blog = r'''
<article style="max-width:640px;margin:0 auto;padding:24px;font-family:Georgia,serif;color:#212121">
  <p style="font-family:Arial,sans-serif;font-size:12px;letter-spacing:2px;color:#e53935;margin:0">DESIGN</p>
  <h1 style="font-size:34px;line-height:1.2;margin:8px 0">Why small interfaces feel faster</h1>
  <p style="font-family:Arial,sans-serif;font-size:13px;color:#757575">By <strong>Mira Patel</strong> &middot; 6 min read</p>
  <img src="https://picsum.photos/id/180/800/400" alt="Desk" style="width:100%;height:200px;object-fit:cover;border-radius:8px">
  <p style="font-size:18px;line-height:1.7">Speed is partly <em>perception</em>. When a screen shows only what matters,
     people decide sooner and <span style="background:#fff59d">trust the result</span> more.</p>
  <blockquote style="margin:20px 0;padding:8px 16px;border-left:4px solid #e53935;color:#616161;font-style:italic">
    Remove everything that does not help the next decision.
  </blockquote>
  <h2 style="font-size:24px">Three habits</h2>
  <ol style="font-size:17px;line-height:1.8">
    <li>Show one primary action per screen.</li>
    <li>Prefer defaults over settings.</li>
    <li>Measure the time to first decision.</li>
  </ol>
  <hr style="border:0;border-top:1px solid #e0e0e0;margin:24px 0">
  <p style="font-family:Arial,sans-serif;font-size:14px;color:#757575">Thanks for reading. <a href="#">Subscribe</a> for more.</p>
</article>''';

const _dashboard = r'''
<div style="font-family:Arial,sans-serif;background:#eef1f6;padding:20px">
  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
    <h1 style="margin:0;font-size:24px;color:#1a237e">Sales overview</h1>
    <span style="background:#e8f5e9;color:#2e7d32;padding:4px 12px;border-radius:12px;font-size:13px">Live</span>
  </div>
  <div style="display:flex;gap:12px;margin-bottom:16px">
    <div style="flex:1;background:#fff;padding:16px;border-radius:10px">
      <div style="color:#757575;font-size:13px">Revenue</div>
      <div style="font-size:26px;font-weight:bold;margin-top:4px">$48,210</div>
      <div style="color:#2e7d32;font-size:13px;margin-top:4px">+12.4%</div>
    </div>
    <div style="flex:1;background:#fff;padding:16px;border-radius:10px">
      <div style="color:#757575;font-size:13px">Orders</div>
      <div style="font-size:26px;font-weight:bold;margin-top:4px">1,284</div>
      <div style="color:#2e7d32;font-size:13px;margin-top:4px">+3.1%</div>
    </div>
    <div style="flex:1;background:#fff;padding:16px;border-radius:10px">
      <div style="color:#757575;font-size:13px">Refunds</div>
      <div style="font-size:26px;font-weight:bold;margin-top:4px">37</div>
      <div style="color:#c62828;font-size:13px;margin-top:4px">-0.8%</div>
    </div>
  </div>
  <div style="background:#fff;border-radius:10px;padding:16px">
    <h2 style="margin:0 0 8px;font-size:16px">Recent orders</h2>
    <table style="width:100%;border-collapse:collapse;font-size:14px">
      <tr style="background:#f5f7fb"><th style="text-align:left;padding:8px">Order</th><th style="text-align:left;padding:8px">Customer</th><th style="text-align:right;padding:8px">Total</th></tr>
      <tr><td style="padding:8px;border-top:1px solid #eceff1">#1042</td><td style="padding:8px;border-top:1px solid #eceff1">Lena Fischer</td><td style="padding:8px;border-top:1px solid #eceff1;text-align:right">$120.00</td></tr>
      <tr><td style="padding:8px;border-top:1px solid #eceff1">#1041</td><td style="padding:8px;border-top:1px solid #eceff1">Omar Haddad</td><td style="padding:8px;border-top:1px solid #eceff1;text-align:right">$86.50</td></tr>
      <tr><td style="padding:8px;border-top:1px solid #eceff1">#1040</td><td style="padding:8px;border-top:1px solid #eceff1">Priya Nair</td><td style="padding:8px;border-top:1px solid #eceff1;text-align:right">$240.90</td></tr>
    </table>
  </div>
</div>''';

const _products = r'''
<div style="font-family:Arial,sans-serif;padding:20px;background:#fafafa">
  <h1 style="margin:0 0 16px;font-size:24px">New arrivals</h1>
  <div style="display:flex;flex-wrap:wrap;gap:16px">
    <div style="width:160px;background:#fff;border-radius:10px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.15)">
      <img src="https://picsum.photos/id/21/320/240" alt="" style="width:100%;height:110px;object-fit:cover">
      <div style="padding:10px"><div style="font-size:14px">Canvas backpack</div><div style="font-weight:bold;margin-top:4px">$59</div></div>
    </div>
    <div style="width:160px;background:#fff;border-radius:10px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.15)">
      <img src="https://picsum.photos/id/96/320/240" alt="" style="width:100%;height:110px;object-fit:cover">
      <div style="padding:10px"><div style="font-size:14px">Ceramic mug</div><div style="font-weight:bold;margin-top:4px">$18</div></div>
    </div>
    <div style="width:160px;background:#fff;border-radius:10px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.15)">
      <img src="https://picsum.photos/id/119/320/240" alt="" style="width:100%;height:110px;object-fit:cover">
      <div style="padding:10px"><div style="font-size:14px">Desk lamp</div><div style="font-weight:bold;margin-top:4px">$42</div></div>
    </div>
    <div style="width:160px;background:#fff;border-radius:10px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.15)">
      <img src="https://picsum.photos/id/160/320/240" alt="" style="width:100%;height:110px;object-fit:cover">
      <div style="padding:10px"><div style="font-size:14px">Wool throw</div><div style="font-weight:bold;margin-top:4px">$75</div></div>
    </div>
  </div>
</div>''';

const _login = r'''
<div style="min-height:100vh;display:flex;flex-direction:column;justify-content:center;align-items:center;
            background:linear-gradient(160deg,#1a237e 0%,#7b1fa2 100%);font-family:Arial,sans-serif">
  <h1 style="color:#fff;font-size:28px;margin:0 0 16px">Welcome back</h1>
  <div style="width:320px;background:#fff;border-radius:16px;padding:24px;box-shadow:0 12px 32px rgba(0,0,0,.35)">
    <label style="font-size:13px;color:#616161">Email</label>
    <input type="email" placeholder="you@example.com" style="width:100%;padding:10px;margin:4px 0 12px;border:1px solid #cfd8dc;border-radius:8px">
    <label style="font-size:13px;color:#616161">Password</label>
    <input type="password" placeholder="Your password" style="width:100%;padding:10px;margin:4px 0 16px;border:1px solid #cfd8dc;border-radius:8px">
    <button style="width:100%;padding:12px;border:0;border-radius:8px;background:#5e35b1;color:#fff;font-size:16px">Sign in</button>
    <p style="text-align:center;font-size:13px;color:#757575;margin:12px 0 0">Forgot your password?</p>
  </div>
</div>''';

const _ticket = r'''
<div style="font-family:Arial,sans-serif;padding:24px;background:#263238">
  <div style="max-width:380px;margin:0 auto;border-radius:20px;overflow:hidden;background:#fff">
    <div style="padding:20px;color:#fff;background:linear-gradient(135deg,#ff6f00 0%,#d81b60 100%)">
      <div style="font-size:12px;letter-spacing:2px">LIVE CONCERT</div>
      <h1 style="margin:6px 0 4px;font-size:28px">Midnight Echoes</h1>
      <div style="font-size:14px">Open-air arena, Berlin</div>
    </div>
    <div style="display:flex;justify-content:space-between;padding:16px 20px">
      <div><div style="font-size:12px;color:#9e9e9e">DATE</div><div style="font-weight:bold">24 Nov 2026</div></div>
      <div><div style="font-size:12px;color:#9e9e9e">DOORS</div><div style="font-weight:bold">19:30</div></div>
      <div><div style="font-size:12px;color:#9e9e9e">SEAT</div><div style="font-weight:bold">B-14</div></div>
    </div>
    <hr style="border:0;border-top:2px solid #e0e0e0;margin:0 20px">
    <div style="padding:16px 20px;display:flex;justify-content:space-between;align-items:center">
      <span style="font-size:22px;font-weight:bold;color:#d81b60">$89.00</span>
      <button style="background:#263238;color:#fff;border:0;padding:10px 20px;border-radius:20px">Add to wallet</button>
    </div>
  </div>
</div>''';

const _menu = r'''
<div style="max-width:520px;margin:0 auto;padding:24px;font-family:Georgia,serif;background:#fffdf7;color:#3e2723">
  <h1 style="text-align:center;font-size:32px;margin:0;letter-spacing:3px">TRATTORIA</h1>
  <p style="text-align:center;font-style:italic;color:#8d6e63;margin:4px 0 20px">Fresh pasta since 1987</p>
  <h2 style="font-size:20px;border-bottom:2px solid #3e2723;padding-bottom:4px">Starters</h2>
  <div style="display:flex;justify-content:space-between;margin:10px 0"><span><strong>Bruschetta</strong><br><small>Tomato, basil, olive oil</small></span><span>$8</span></div>
  <div style="display:flex;justify-content:space-between;margin:10px 0"><span><strong>Burrata</strong><br><small>Roasted peppers, rocket</small></span><span>$12</span></div>
  <h2 style="font-size:20px;border-bottom:2px solid #3e2723;padding-bottom:4px;margin-top:24px">Pasta</h2>
  <div style="display:flex;justify-content:space-between;margin:10px 0"><span><strong>Tagliatelle al ragù</strong><br><small>Slow-cooked beef sauce</small></span><span>$16</span></div>
  <div style="display:flex;justify-content:space-between;margin:10px 0"><span><strong>Cacio e pepe</strong><br><small>Pecorino, black pepper</small></span><span>$14</span></div>
  <hr style="border:0;border-top:1px solid #d7ccc8;margin:24px 0 12px">
  <p style="text-align:center;font-size:13px;color:#8d6e63">Allergies? Please tell your server.</p>
</div>''';
