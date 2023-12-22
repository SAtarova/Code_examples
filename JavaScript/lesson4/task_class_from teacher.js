// function details() {
//     alert(`Производитель: ${car.proizvoditel}\n
//            Модель: ${car.model}\n
//            Год производства: ${car.year_of_create}\n
//            Средняя скорость: ${car.averag_speed}`)
// }

// function wasteOfTime(distance) {
//     time = distance / car.averag_speed
//     stops = Math.round(time / 4)
//     if (time % 4 == 0) {
//         return (time + stops - 1) 
//     }
//     return (time + stops)
// }

// var car = {
//     proizvoditel: 'BWM',
//     model: '123',
//     year_of_create: 2009,
//     averag_speed: 100
// }

// details()

// console.log(wasteOfTime(1200))


var drob1 = {
    chislitel: +prompt(),
    znamenatel: +prompt()
}

var drob2 = {
    chislitel: 3,
    znamenatel: 15
}

function drobSum(dr1, dr2) {
    let dr = {
        chislitel: null,
        znamenatel: null
    }
    if (dr1.znamenatel == dr2.znamenatel) {
        dr.znamenatel = dr1.znamenatel
        dr.chislitel = dr1.chislitel + dr2.chislitel
        return dr
    } else {
        dr.znamenatel = dr1.znamenatel * dr2.znamenatel
        dr.chislitel = dr1.chislitel * dr2.znamenatel + dr2.chislitel * dr1.znamenatel
        return dr
    }
}

function drobMinus(dr1, dr2) {
    let dr = {
        chislitel: null,
        znamenatel: null
    }
    if (dr1.znamenatel == dr2.znamenatel) {
        dr.znamenatel = dr1.znamenatel
        dr.chislitel = dr1.chislitel - dr2.chislitel
        return dr
    } else {
        dr.znamenatel = dr1.znamenatel * dr2.znamenatel
        dr.chislitel = dr1.chislitel * dr2.znamenatel - dr2.chislitel * dr1.znamenatel
        return dr
    }
}

function drobMultiple(dr1, dr2) {
    let dr = {
        chislitel: null,
        znamenatel: null
    }
    dr.znamenatel = dr1.znamenatel * dr2.znamenatel
    dr.chislitel = dr1.chislitel * dr2.chislitel
    return dr
}

function drobDivide(dr1, dr2) {
    let dr = {
        chislitel: null,
        znamenatel: null
    }
    dr.znamenatel = dr1.znamenatel * dr2.chislitel
    dr.chislitel = dr1.chislitel * dr2.znamenatel
    return dr
}

function decrease(drob) {
    let dr = {
        chislitel: drob.chislitel,
        znamenatel: drob.znamenatel
    }
    for (let i = 2; i <= dr.chislitel; i++) {
        if (dr.chislitel % i == 0 && dr.znamenatel % i == 0){
            dr.chislitel = dr.chislitel / i;
            dr.znamenatel = dr.znamenatel / i;
            console.log(dr.chislitel, dr.znamenatel)
        }
    }
    return dr
}


console.log(decrease(drob1))
