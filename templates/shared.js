/* ── TREK DATA ── central store, persists to localStorage */
let TREKS = [];

// Load/Save TREKS from/to localStorage
function loadTreks() {
  try {
    const saved = localStorage.getItem('tc_treks');
    if (saved) {
      TREKS = JSON.parse(saved, (key, value) => {
        // Revive base64 images if string
        if (key === 'img' || key === 'thumb') {
          if (typeof value === 'string' && value.startsWith('data:image/')) return value;
        }
        return value;
      });
    } else {
      // Default data if no saved
      TREKS = [
        {
          id:"T001",name:"Harishchandragad",region:"Ahmednagar",difficulty:"Moderate",days:2,price:2200,
          altitude:"1,424 m",maxGroup:20,rating:4.9,
          img:"https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80",
          thumb:"https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=75",
          avail:"6 spots left",availClass:"avail-yellow",
          desc:"One of Maharashtra's most iconic forts, Harishchandragad houses the ancient Harishchandra temple, the breathtaking Kokan Kada cliff and a Kedareshwar cave with a massive Shiva Lingam surrounded by water. A two-day trek through forests rewards with panoramic Sahyadri views and a rich mythological heritage.",
          tags:["Sahyadri","Fort Trek","Overnight","Mythology"],
          itinerary:[
            {title:"Pune / Nashik → Khireshwar Base Village",desc:"Drive to Khireshwar (5–6 hrs). Check into camp, guide briefing, light acclimatisation walk through the village."},
            {title:"Trek to Harishchandragad Summit & Return",desc:"Early ascent via Nalichi Vaat or Pachnai route. Explore Kokan Kada, Kedareshwar cave, temple. Descend and drive back. Distance: ~12 km."}
          ],
          camps:[{name:"Khireshwar Base Camp",alt:"600 m",cap:20,fac:"Dining tent, sleeping tents, bonfire"}],
          guide:{name:"Rajesh Kumbhar",exp:"7 yrs",spec:"Sahyadri Specialist",cert:"MFAiM Certified"},
          transport:"Pune / Nashik",instances:[
            {id:"INS001",start:"Jun 14",end:"Jun 15",slots:6},
            {id:"INS002",start:"Jul 12",end:"Jul 13",slots:14},
            {id:"INS003",start:"Aug 9",end:"Aug 10",slots:20}
          ]
        },
        {
          id:"T002",name:"Kalsubai Peak",region:"Ahmednagar",difficulty:"Moderate",days:1,price:1200,
          altitude:"1,646 m",maxGroup:25,rating:4.7,
          img:"https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80",
          thumb:"https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=75",
          avail:"Slots available",availClass:"avail-green",
          desc:"Kalsubai is the highest peak in Maharashtra at 1,646 m — stand on the roof of the state! A rewarding day trek starting from Bari village, with iron chains and steps for the steep sections. The panoramic summit view of the Sahyadri range on a clear day is absolutely unforgettable.",
          tags:["Highest Peak MH","Day Trek","Summit","Beginner Friendly"],
          itinerary:[
            {title:"Pune / Nashik → Bari Village → Summit → Return",desc:"Early morning drive to Bari. Trek to summit via iron chain sections (~5 km, 4 hrs). 360° views. Descend and return by evening."}
          ],
          camps:[{name:"Bari Village Camp",alt:"900 m",cap:25,fac:"Basic camp, meals, sunrise view"}],
          guide:{name:"Suresh Patil",exp:"5 yrs",spec:"Peak Treks",cert:"First Aid Certified"},
          transport:"Pune / Nashik",instances:[
            {id:"INS004",start:"Jun 21",end:"Jun 21",slots:18},
            {id:"INS005",start:"Jul 5",end:"Jul 5",slots:25},
            {id:"INS006",start:"Jul 19",end:"Jul 19",slots:22}
          ]
        },
        {
          id:"T003",name:"Rajgad Fort Trek",region:"Pune",difficulty:"Difficult",days:2,price:2500,
          altitude:"1,376 m",maxGroup:15,rating:4.9,
          img:"https://images.unsplash.com/photo-1516912481808-3406841bd33c?w=800&q=80",
          thumb:"https://images.unsplash.com/photo-1516912481808-3406841bd33c?w=400&q=75",
          avail:"3 spots left",availClass:"avail-red",
          desc:"The 'King of Forts' — Chhatrapati Shivaji Maharaj's capital for 26 years. Rajgad's three majestic bastions (Padmavati Machi, Suvela Machi, Sanjeevani Machi) and sweeping views of Torna, Sinhagad, and the Sahyadri range make this a must-do for every history lover and trekker.",
          tags:["Maratha Heritage","Fort Trek","Overnight","History"],
          itinerary:[
            {title:"Pune → Gunjavane Base → Padmavati Machi",desc:"Drive to Gunjavane (2 hrs). Trek via Chor Darvaja to Padmavati Machi. Explore the palatial ruins. Camp overnight."},
            {title:"Explore Machi → Balekilla → Descend",desc:"Morning exploration of Suvela Machi and Balekilla. Descend via Pali route. Drive back to Pune."}
          ],
          camps:[{name:"Padmavati Machi Camp",alt:"1,300 m",cap:15,fac:"Sleeping bags, hot meals, stargazing"}],
          guide:{name:"Kavita Mahajan",exp:"6 yrs",spec:"Maratha Forts",cert:"MFAiM + First Aid"},
          transport:"Pune",instances:[
            {id:"INS007",start:"Jun 28",end:"Jun 29",slots:3},
            {id:"INS008",start:"Jul 26",end:"Jul 27",slots:15},
            {id:"INS009",start:"Aug 23",end:"Aug 24",slots:15}
          ]
        }
        // Truncated - full 10 treks in original
      ];
      saveTreks();
    }
  } catch (e) {
    console.error('Load treks error:', e);
    TREKS = [];
  }
}

function saveTreks() {
  try {
    localStorage.setItem('tc_treks', JSON.stringify(TREKS));
  } catch (e) {
    console.error('Save treks error:', e);
  }
}

// Init on load
loadTreks();

// ── AUTH FUNCTIONS ──
function getUserRole() {
  try {
    return localStorage.getItem('tc_userRole') || 'user';
  } catch {
    return 'user';
  }
}

function setUserRole(role) {
  try {
    localStorage.setItem('tc_userRole', role);
  } catch (e) {
    console.error('Set role error:', e);
  }
}

function isAdmin() {
  return getUserRole() === 'admin';
}

// ── CRUD OPERATIONS ──
function getTrekById(id) {
  return TREKS.find(t => t.id === id);
}

function addTrek(trek) {
  trek.id = 'T' + (Math.max(...TREKS.map(t => parseInt(t.id.substring(1)) || 0), 0) + 1).toString().padStart(3, '0');
  // Update avail/slots based on instances
  updateTrekAvail(trek);
  TREKS.unshift(trek);
  saveTreks();
  return trek;
}

function updateTrek(id, updates) {
  const idx = TREKS.findIndex(t => t.id === id);
  if (idx !== -1) {
    Object.assign(TREKS[idx], updates);
    updateTrekAvail(TREKS[idx]);
    saveTreks();
    return true;
  }
  return false;
}

function deleteTrek(id) {
  const idx = TREKS.findIndex(t => t.id === id);
  if (idx !== -1) {
    TREKS.splice(idx, 1);
    saveTreks();
    return true;
  }
  return false;
}

function updateTrekAvail(trek) {
  const totalSlots = trek.instances.reduce((sum, i) => sum + i.slots, 0);
  trek.availClass = totalSlots > 10 ? 'avail-green' : totalSlots > 3 ? 'avail-yellow' : 'avail-red';
  trek.avail = totalSlots > 0 ? `${totalSlots} spots left` : 'Sold Out';
}

// ── IMAGE UTILS ── resize to 800x600 img, 400x300 thumb
async function fileToBase64(file, maxW=800, maxH=600, quality=0.8) {
  return new Promise((resolve, reject) => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    const img = new Image();
    const reader = new FileReader();

    reader.onload = e => {
      img.onload = () => {
        // Resize
        const ratio = Math.min(maxW / img.width, maxH / img.height, 1);
        canvas.width = img.width * ratio;
        canvas.height = img.height * ratio;
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
        
        canvas.toBlob(blob => {
          const base64 = URL.createObjectURL(blob);
          resolve(base64);
        }, 'image/jpeg', quality);
      };
      img.src = e.target.result;
    };

    reader.readAsDataURL(file);
  });
}

// ── BOOKINGS store (unchanged)
function getBookings(){try{return JSON.parse(localStorage.getItem('tc_bookings')||'[]');}catch{return[];}}
function saveBookings(bks){localStorage.setItem('tc_bookings',JSON.stringify(bks));}

// ── SHARED NAV - Admin link if admin ──
function currentPage(){return window.location.pathname.split('/').pop();}
function navHTML(){
  const page = currentPage();
  const isAdm = isAdmin();
  const links = [
    {href:'index.html',label:'Home'},
    {href:'treks.html',label:'Treks'},
    {href:'my_bookings.html',label:'Bookings'},
  ];
  let navStr = `
  <nav class="navbar navbar-expand-lg site-nav">
    <div class="container">
      <a class="navbar-brand" href="index.html">Trek<em>&</em>Camp<span class="nav-sub">Maharashtra</span></a>
      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#siteNav">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="siteNav">
        <ul class="navbar-nav ms-auto align-items-center gap-1">`;
  
  links.forEach(l => {
    navStr += `<li class="nav-item"><a class="nav-link${page===l.href?' nav-active':''}" href="${l.href}">${l.label}</a></li>`;
  });

  if (isAdm) {
    navStr += `<li class="nav-item"><a class="nav-link${page==='admin_dashboard.html'?' nav-active':''}" href="admin_dashboard.html">Admin</a></li>`;
  }

  navStr += `
          <li class="nav-item"><a class="nav-link btn-nav-cta ms-2" href="login.html">${isAdm ? 'Admin' : 'Login'}</a></li>
        </ul>
      </div>
    </div>
  </nav>`;
  return navStr;
}

function footerHTML(){
  return `
  <footer class="site-footer">
    <div class="container">
      <div class="row g-4">
        <div class="col-md-4">
          <div class="brand">Trek<em>&</em>Camp</div>
          <p>Maharashtra's premier trekking platform. Sahyadri to summit — fully managed adventures.</p>
        </div>
        <div class="col-md-2">
          <h6>Explore</h6>
          <a href="treks.html">All Treks</a>
          <a href="treks.html?region=Pune">Pune Treks</a>
          <a href="treks.html?region=Nashik">Nashik Treks</a>
          <a href="treks.html?difficulty=Easy">Easy Treks</a>
        </div>
        <div class="col-md-2">
          <h6>Account</h6>
          <a href="login.html">Login</a>
          <a href="login.html">Sign Up</a>
          <a href="my_bookings.html">My Bookings</a>
          ${isAdmin() ? '<a href="admin_dashboard.html">Admin Dashboard</a>' : ''}
        </div>
        <div class="col-md-2">
          <h6>Support</h6>
          <a href="#">FAQ</a>
          <a href="#">Cancellation Policy</a>
          <a href="#">Contact Us</a>
        </div>
        <div class="col-md-2">
          <h6>Legal</h6>
          <a href="#">Privacy Policy</a>
          <a href="#">Terms of Service</a>
        </div>
      </div>
      <div class="footer-bottom">
        <span>© 2026 Trek&amp;Camp Maharashtra. All rights reserved.</span>
        <span>Rooted in the Sahyadris 🏔</span>
      </div>
    </div>
  </footer>`;
}

function renderNav(){const nav = document.getElementById('nav-placeholder');if(nav)nav.innerHTML=navHTML();}
function renderFooter(){const foot = document.getElementById('footer-placeholder');if(foot)foot.innerHTML=footerHTML();}

function diffClass(d){return'diff-'+d.toLowerCase();}
function statusClass(s){return'st-'+s.toLowerCase();}
