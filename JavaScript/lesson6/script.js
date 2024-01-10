





class Button {
    constructor(width, height, text) {
        this.width = width;
        this.text = text;
        this.height = height;
    }

    showBtn() {
        document.write(`<button style='width:${this.width}px; height:${this.height}px'>${this.text}</button>`)
    }
}

class BootstrapButton extends Button {
    constructor(width, height, text, color){
        super(width, height, text);
        this.color = color;
    }

    showBtn() {
        document.write(`<button style='width:${this.width}px; height:${this.height}px; background-color:${this.color}'>
        ${this.text}</button>`)
    }
}


let a = new Button(300, 300, 'RandomText')
let b = new Button(500, 500, 'TheMostRandomText')

a.showBtn()
b.showBtn()

let c = new BootstrapButton(700, 700, 'TheMOSTMostRandomText', 'green')
c.showBtn()
///////////////////////////////////////////////////////////////////////////


class Figure {
    constructor(name, sideCount, sideLen) {
        this._name = name;
        this.sideCount = sideCount;
        this.sideLen = sideLen;
    }

    get name() {
        return this._name
    }

    print() {
        console.log(this.sideCount, this.sideLen)
    }

    squareRes() {
        return false
    }

    perimetrRes() {
        return this.sideLen * this.sideCount
    }
}

class Square extends Figure {
    constructor(sideLen) {
        super('square', 4, sideLen)
    }

    squareRes() {
        return this.sideLen * this.sideLen
    }
}

class Rectangle extends Figure {
    constructor(sideLen, sideLenB) {
        super('rectangle', 4, sideLen);
        this.sideLenB = sideLenB;
    }

    squareRes() {
        return this.sideLenB * this.sideLen
    }

    perimetrRes() {
        return this.sideLen*2 + this.sideLenB*2
    }
}


class Triangle extends Figure {
    constructor(sideLen) {
        super('triangle', 3, sideLen)
    }

    squareRes() {
        return (Math.pow(this.sideLen, 2) * Math.pow(3, 1/2)) / 4
    }

    perimetrRes() {
        return this.sideLen*3
    }
}

let a = new Rectangle(10, 20)
console.log(a.perimetrRes())
console.log(a.squareRes())

let b = new Square(12)
console.log(b)

let c = new Triangle(10)
console.log(c.perimetrRes())
console.log(c.squareRes())
console.log(c.name)
///////////////////////////////////////////////////////////////


class ExtendedArray extends Array {

    getString(separator) {
        return this.join(separator)
    }

    getHtml(tagName) {
        let result = '';
        if (tagName == 'li'){
            result += '<ul>\n'
            for (let i = 0; i < this.length; i++) {
                result += `<li>${this[i]}</li>\n`
            }
            result += '</ul>'
            document.write(result)
            return result
        }
        for (let i = 0; i < this.length; i++) {
            result += `<${tagName}>${this[i]}</${tagName}>\n`
        } 
        document.write(result)
        return result 
    }
}


let a = new ExtendedArray(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
console.log(a.getString('-'))
a.getHtml('li')
a.getHtml('div')




