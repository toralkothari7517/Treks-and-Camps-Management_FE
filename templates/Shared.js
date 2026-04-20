/* ── TREK DATA ── central store, all pages read from this */
const TREKS = [
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
  },
  {
    id:"T004",name:"Rajmachi Trek",region:"Pune",difficulty:"Easy",days:2,price:1800,
    altitude:"920 m",maxGroup:25,rating:4.6,
    img:"https://images.unsplash.com/photo-1518623489648-a173ef7824f3?w=800&q=80",
    thumb:"https://images.unsplash.com/photo-1518623489648-a173ef7824f3?w=400&q=75",
    avail:"Slots available",availClass:"avail-green",
    desc:"Rajmachi offers a perfect first-time overnight trek experience. The trail winds through dense forests and the twin forts of Shrivardhan and Manaranjan offer spectacular views of the Ulhas valley. Lush green monsoon scenery makes this one of Maharashtra's most photogenic treks.",
    tags:["Easy","First-Timer","Twin Forts","Monsoon"],
    itinerary:[
      {title:"Lonavala → Kondivade Village → Rajmachi Camp",desc:"Trek from Lonavala via the forest trail to the base camp near Udhewadi village (~12 km). Explore Shrivardhan Fort."},
      {title:"Manaranjan Fort → Return to Lonavala",desc:"Morning visit to Manaranjan Fort. Descend back via the forest trail. Return by afternoon."}
    ],
    camps:[{name:"Udhewadi Village Camp",alt:"880 m",cap:25,fac:"Homestay style, local food, bonfire"}],
    guide:{name:"Anand Desai",exp:"4 yrs",spec:"Western Ghats",cert:"First Aid"},
    transport:"Lonavala / Pune",instances:[
      {id:"INS010",start:"Jun 21",end:"Jun 22",slots:20},
      {id:"INS011",start:"Jul 19",end:"Jul 20",slots:25},
      {id:"INS012",start:"Aug 16",end:"Aug 17",slots:25}
    ]
  },
  {
    id:"T005",name:"Torna Fort Trek",region:"Pune",difficulty:"Moderate",days:1,price:1100,
    altitude:"1,403 m",maxGroup:20,rating:4.8,
    img:"https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80",
    thumb:"https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=75",
    avail:"Slots available",availClass:"avail-green",
    desc:"Torna, also known as Prachandagad, was the first fort captured by the 16-year-old Shivaji Maharaj in 1646. At 1,403 m it's one of the highest forts in Maharashtra. The trek from Velhe village is well-marked and offers fabulous views of Rajgad, Sinhagad, and Purandar.",
    tags:["Historic","Day Trek","Shivaji","Sahyadri"],
    itinerary:[
      {title:"Pune → Velhe → Torna Summit → Return",desc:"Drive to Velhe base (2 hrs). Trek to summit via main path (~3 km, 3 hrs). Explore Mengai Devi temple, Zunjar Machi. Descend and return to Pune by evening."}
    ],
    camps:[{name:"Velhe Base Camp",alt:"700 m",cap:20,fac:"Basic camp, breakfast and lunch"}],
    guide:{name:"Vijay Shinde",exp:"5 yrs",spec:"Pune District Forts",cert:"Wilderness First Aid"},
    transport:"Pune",instances:[
      {id:"INS013",start:"Jun 22",end:"Jun 22",slots:15},
      {id:"INS014",start:"Jul 6",end:"Jul 6",slots:20},
      {id:"INS015",start:"Aug 3",end:"Aug 3",slots:20}
    ]
  },
  {
    id:"T006",name:"Kalavantin Durg",region:"Raigad",difficulty:"Difficult",days:1,price:1400,
    altitude:"2,300 ft",maxGroup:15,rating:4.8,
    img:"https://images.unsplash.com/photo-1454496522488-7a8e488e8606?w=800&q=80",
    thumb:"https://images.unsplash.com/photo-1454496522488-7a8e488e8606?w=400&q=75",
    avail:"8 spots left",availClass:"avail-yellow",
    desc:"Kalavantin Durg is one of the most thrilling and visually dramatic treks near Mumbai. The rock-cut steps carved into near-vertical walls leading to a tiny plateau at the summit are an adrenaline rush. The view of Prabal Fort, Matheran hills, and the Arabian Sea on clear days is jaw-dropping.",
    tags:["Thrilling","Near Mumbai","Rock-cut Steps","Views"],
    itinerary:[
      {title:"Mumbai / Pune → Prabal Village → Summit → Return",desc:"Early drive to Prabal Machi base. Trek to Kalavantin Durg summit via rock-cut steps. Not for vertigo sufferers! Return by afternoon."}
    ],
    camps:[{name:"Prabal Base Camp",alt:"550 m",cap:15,fac:"Rest area, snacks, safety briefing"}],
    guide:{name:"Nilesh Jadhav",exp:"6 yrs",spec:"Konkan & Raigad Treks",cert:"Rock Craft + First Aid"},
    transport:"Mumbai / Pune",instances:[
      {id:"INS016",start:"Jun 15",end:"Jun 15",slots:8},
      {id:"INS017",start:"Jul 13",end:"Jul 13",slots:15},
      {id:"INS018",start:"Aug 10",end:"Aug 10",slots:15}
    ]
  },
  {
    id:"T007",name:"Alang Madan Kulang",region:"Nashik",difficulty:"Extreme",days:3,price:4500,
    altitude:"1,300+ m",maxGroup:10,rating:5.0,
    img:"https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=800&q=80",
    thumb:"https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=400&q=75",
    avail:"4 spots left",availClass:"avail-red",
    desc:"AMK (Alang-Madan-Kulang) is the Holy Trinity of trekking in Maharashtra — three consecutive forts considered the toughest multi-fort trek in the Sahyadris. Technical sections require rope usage. Only for experienced trekkers. Completing all three is a badge of honour in Maharashtra's trekking community.",
    tags:["Extreme","Technical","Multi-Fort","Expert Only"],
    itinerary:[
      {title:"Nashik → Ambivali Base → Alang Fort",desc:"Drive to Ambivali. Full day technical climb to Alang — rope sections, overhangs. Camp inside the fort."},
      {title:"Alang → Madan Fort",desc:"Short but technical traverse to Madan. Explore caves and water cisterns. Overnight camp."},
      {title:"Madan → Kulang → Descent",desc:"Kulang traverse, final descent. Return to Nashik / Pune by evening."}
    ],
    camps:[{name:"Alang Fort Camp",alt:"1,280 m",cap:10,fac:"Sleeping bags, trail meals, emergency gear"},{name:"Madan Fort Camp",alt:"1,300 m",cap:10,fac:"Sleeping bags, trail meals"}],
    guide:{name:"Prashant Wagh",exp:"10 yrs",spec:"Technical & Extreme Treks",cert:"MFAiM + Rope Craft Expert"},
    transport:"Nashik",instances:[
      {id:"INS019",start:"Jun 27",end:"Jun 29",slots:4},
      {id:"INS020",start:"Aug 1",end:"Aug 3",slots:10}
    ]
  },
  {
    id:"T008",name:"Sinhagad Fort Trek",region:"Pune",difficulty:"Easy",days:1,price:800,
    altitude:"1,312 m",maxGroup:30,rating:4.5,
    img:"https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=800&q=80",
    thumb:"https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=400&q=75",
    avail:"Slots available",availClass:"avail-green",
    desc:"Sinhagad — the Lion's Fort — is synonymous with Pune's trekking culture. The fort of the legendary Tanaji Malusare is just 25 km from the city, making it perfect for first-time trekkers. The night trek version is especially popular, with Pune's city lights glittering below.",
    tags:["Near Pune","Night Trek","Beginners","Iconic"],
    itinerary:[
      {title:"Pune → Donje Village → Fort → Return",desc:"Short drive to Donje base. Ascent via the well-paved path (~30 min). Explore the fort, Tanaji memorial, Kondana caves. Return by noon. Option: night trek version departs at midnight."}
    ],
    camps:[{name:"Donje Base Camp",alt:"600 m",cap:30,fac:"Tea, snacks, morning breakfast"}],
    guide:{name:"Ramesh Gore",exp:"8 yrs",spec:"Night Treks & Urban Trails",cert:"Wilderness First Aid"},
    transport:"Pune",instances:[
      {id:"INS021",start:"Jun 22",end:"Jun 22",slots:25},
      {id:"INS022",start:"Jul 13",end:"Jul 13",slots:30},
      {id:"INS023",start:"Jul 20",end:"Jul 20",slots:30}
    ]
  },
  {
    id:"T009",name:"Bhimashankar Trek",region:"Pune",difficulty:"Moderate",days:2,price:2000,
    altitude:"1,000 m",maxGroup:20,rating:4.7,
    img:"https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=800&q=80",
    thumb:"https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=400&q=75",
    avail:"Slots available",availClass:"avail-green",
    desc:"Bhimashankar is a dual delight — a sacred Jyotirlinga shrine and a biodiversity hotspot. The trek through the Bhimashankar Wildlife Sanctuary reveals giant squirrels, leopard pugmarks, and an incredible diversity of birds and plants. One of Maharashtra's most scenic overnight treks.",
    tags:["Wildlife","Jyotirlinga","Overnight","Biodiversity"],
    itinerary:[
      {title:"Pune → Khandas Base → Bhimashankar",desc:"Drive to Khandas (2 hrs). Trek through the wildlife sanctuary, dense sholas, and waterfalls to reach the Bhimashankar temple. Camp nearby."},
      {title:"Bhimashankar → Return via Ganpati Ghat",desc:"Morning darshan at the temple. Descent via the scenic Ganpati Ghat path. Return to Pune by afternoon."}
    ],
    camps:[{name:"Bhimashankar Camp",alt:"980 m",cap:20,fac:"Tent stay, vegetarian meals, bonfire"}],
    guide:{name:"Deepa Kulkarni",exp:"5 yrs",spec:"Wildlife & Sanctuary Treks",cert:"Wildlife Guide License"},
    transport:"Pune",instances:[
      {id:"INS024",start:"Jun 28",end:"Jun 29",slots:16},
      {id:"INS025",start:"Jul 26",end:"Jul 27",slots:20},
      {id:"INS026",start:"Aug 23",end:"Aug 24",slots:20}
    ]
  },
  {
    id:"T010",name:"Naneghat Trek",region:"Thane",difficulty:"Easy",days:1,price:900,
    altitude:"838 m",maxGroup:25,rating:4.6,
    img:"https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80",
    thumb:"https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&q=75",
    avail:"Slots available",availClass:"avail-green",
    desc:"Naneghat is an ancient mountain pass used by traders over 2,000 years ago as a toll route between the Konkan coast and the Deccan plateau. The plateau offers a stunning sea of clouds during monsoon and sweeping valley views. The cave inscriptions are among Maharashtra's oldest discovered.",
    tags:["Ancient Pass","Easy","Monsoon","Historic"],
    itinerary:[
      {title:"Mumbai / Pune → Tokavde Village → Naneghat → Return",desc:"Drive to Tokavde (3 hrs from Mumbai). Trek to the plateau via the ancient stone-cut path (~4 km, 2 hrs). Explore the Satavahana inscriptions in the cave. Return by afternoon."}
    ],
    camps:[{name:"Tokavde Base Camp",alt:"400 m",cap:25,fac:"Basic camp, snacks, tea"}],
    guide:{name:"Santosh Bhoir",exp:"4 yrs",spec:"Konkan & Thane Treks",cert:"First Aid"},
    transport:"Mumbai / Thane",instances:[
      {id:"INS027",start:"Jun 29",end:"Jun 29",slots:22},
      {id:"INS028",start:"Jul 27",end:"Jul 27",slots:25},
      {id:"INS029",start:"Aug 24",end:"Aug 24",slots:25}
    ]
  }
];

// ── BOOKINGS store (session-like, persists via localStorage) ──
function getBookings(){try{return JSON.parse(localStorage.getItem('tc_bookings')||'[]');}catch{return[];}}
function saveBookings(bks){localStorage.setItem('tc_bookings',JSON.stringify(bks));}
function getTrekById(id){return TREKS.find(t=>t.id===id);}

// ── SHARED NAV HTML ──
function currentPage(){return window.location.pathname.split('/').pop();}
function navHTML(){
  const page = currentPage();
  const links = [
    {href:'treks.html',label:'Treks'},
    {href:'#',label:'Camps'},
    {href:'#',label:'Guides'},
    {href:'my_bookings.html',label:'My Bookings'},
  ];
  return `
  <nav class="navbar navbar-expand-lg site-nav">
    <div class="container">
      <a class="navbar-brand" href="index.html">Trek<em>&</em>Camp<span class="nav-sub">Maharashtra</span></a>
      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#siteNav">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="siteNav">
        <ul class="navbar-nav ms-auto align-items-center gap-1">
          ${links.map(l=>`<li class="nav-item"><a class="nav-link${page===l.href?' nav-active':''}" href="${l.href}">${l.label}</a></li>`).join('')}
          <li class="nav-item"><a class="nav-link btn-nav-cta ms-2" href="login.html">Login / Sign Up</a></li>
        </ul>
      </div>
    </div>
  </nav>`;
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

function renderNav(){document.getElementById('nav-placeholder').innerHTML=navHTML();}
function renderFooter(){document.getElementById('footer-placeholder').innerHTML=footerHTML();}

function diffClass(d){return'diff-'+d.toLowerCase();}
function statusClass(s){return's t-'+s.toLowerCase();}