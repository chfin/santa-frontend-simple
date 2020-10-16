// announcing santas
// =================

function announce() {
    var name = document.getElementById("name").value;
    if (name in assignment) {
        alert(assignment[name]);
    } else {
        alert("Herzlichen Glückwunsch, du hast es geschafft, deinen eigenen Namen falsch zu schreiben. Versuch's nochmal...");
    }
}

document.getElementById("pushbutton").onclick = announce;
document.getElementById("name").onkeydown = function() {
    if (event.key === 'Enter') {
        announce();
    }
};

var santalist = document.getElementById("santas");
for (var santa of Object.keys(assignment)) {
    var li = document.createElement("LI");
    li.appendChild(document.createTextNode(santa));
    santalist.appendChild(li);
}

// wishlist
// ========

const h = maquette.h;
const projector = maquette.createProjector();

var wishdiv = document.getElementById("wishlist");
var wishlist = [];

function fetchWishes() {
    getWishes(
        function (data) {
            wishlist = data;
            projector.scheduleRender();
        },
        function (error) {
            alert("Wunschliste konnte nicht geladen werden: " + error);
        }
    );
}
fetchWishes();

function deleteWish(id, content) {
    console.log("deleting "+id);
    if (confirm("Sicher, dass du an "+content+" nicht mehr interessiert bist? Na gut, dann lösche ich das jetzt mal."))
    deleteWishByWishid(
        id,
        function () { fetchWishes(); },
        function (err) { alert("Verwünscht! Ein Fehler ist aufgetreten: "+err); }
    );
}

function addWish() {
    var input = document.getElementById("newWish");
    var content = input.value;
    console.log("adding wish "+content);
    postAddWish(
        content,
        function () { fetchWishes(); },
        function (err) { alert("Verwünscht! Ein Fehler ist aufgetreten: "+err); }
    );
    input.value = "";
}

function renderWishlist() {
    var wishes = wishlist.map(
        w => h('li', {key: w.wishId}, [
            w.wishContent, " ",
            h('a.delete',
              {onclick: function () { deleteWish(w.wishId, w.wishContent); }},
              ["(löschen)"])
        ])
    );
    console.log(wishes);
        
    return h('div', [
        h('ul', wishes),
        h('div', [
            h('input#newWish',
              {type: "text",
               onkeydown: function() {
                   if (event.key === 'Enter') {
                       addWish();
                   }
               }}),
            h('input',
              {type: "button",
               onclick: function() { addWish(); },
               value: "Wünschen!"})
        ])
    ]);
}

if (wishlist) {
    projector.append(wishdiv, renderWishlist);
}
