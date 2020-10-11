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
