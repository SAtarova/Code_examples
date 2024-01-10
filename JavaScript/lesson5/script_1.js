class HtmlElement {

    constructor(tag = '', selfClose = false, text = '', atribs = [], styles = [], nestedElems = []) {
        this.tag = tag;
        this.selfClose = selfClose;
        this.text = text;
        this.atribs = atribs;
        this.styles = styles;
        this.nestedElems = nestedElems;
    }

     addAtrib(value) {
        this.atribs.push(value)
    }

    addStyle(value) {
        this.styles.push(value)
    }

    addTail(elem) {
        this.nestedElems.push(elem)
    }

    addHead(elem) {
        this.nestedElems.unshift(elem)
    }

    getHtml() {
        let code = '<' + this.tag + ' '

        for (let i of this.atribs) {
            code += i + ' '
        }
        code += `style='`
        for (let i of this.styles) {
            code += i + ';'
        }
        if (this.selfClose) {
            code += "'/>"
        } else {
            code += "'>"
        }
        code += '\n'
        for (let i of this.nestedElems){
            code += i.getHtml() +'\n'
        }
        if (this.text.length > 0) {
            code += this.text
        }
        if (!this.selfClose) {
            code += '</' + this.tag + '>'
        }
        return code;
    }
}

let h3 = new HtmlElement('h3', false, 'What is Ipsum Lorem?', [], [], [])
let image = new HtmlElement('img', true, '', ['src="lipsum.jpg"', 'alt="Lorem Ipsum"'], ['width: 100%'], [])
let innerP = new HtmlElement('p', false, 'Lorem Ipsum X 10000', [], ['text-align: justify'], [])

let fDiv = new HtmlElement('div', false, '', ['class = "block"'], ['width: 300px', 'margin: 10px'], [h3, image, innerP])




class CssClass {
    constructor(name, styles){
        this.name = name;
        this.styles = styles;
    }

    addStyle(value) {
        this.styles.push(value)
    }

    removeStyle() {
        this.styles.pop()
    }

    getCss() {
        let code = `.${this.name} {`
        for (let i of this.styles) {
            code += i + ';\n'
        }
        code += '}'
        return code
    }
}

let b = new CssClass('block', ['background: red', 'width: 300px'])



class HtmlBlock {
    constructor(html, css) {
        this.html = html;
        this.css = css;
    }

    getCode() {
        let code = '<style>\n'
        for (let i of this.css) {
            code += i.getCss() + '\n'
        }
        code += '</style>\n'
        code += this.html.getHtml()
        return code;
    }
}

let c = new HtmlBlock(fDiv, [b])
console.log(c.getCode())
document.write(c.getCode())