const _k = [13, 37, 42];
const _d = [33, 61, 50, 3, 56, 254, 35, 200, 245, 26, 8, 226, 184, 29, 227, 182, 251, 211, 237, 209, 237, 5, 2, 193, 157, 143, 181, 238, 228, 181, 126, 130, 232, 220, 209, 173, 121, 108, 161, 192, 204, 176, 182, 96, 170, 155, 131, 169, 175, 160, 120, 67, 146, 142, 157, 118, 91, 134, 129, 122, 101, 20, 134, 134, 112, 76];

function check(flag) {
    if (flag.length !== _d.length) {
        return false;
    }
    let enc = [];
    for (let i = 0; i < flag.length; i++) {
        let c = flag.charCodeAt(i);
        c = c ^ _k[i % _k.length];
        c = (c + i * 3 + 7) & 0xFF;
        enc.push(c);
    }
    enc.reverse();
    for (let i = 0; i < enc.length; i++) {
        if (enc[i] !== _d[i]) {
            return false;
        }
    }
    return true;
}

const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('Enter flag: ', (input) => {
    if (check(input)) {
        console.log('Gacor');
    } else {
        console.log('Tolong kasih flag yg bener le.');
    }
    rl.close();
});
