// class PrintMachine {
//     constructor (size, color, font_family) {
//         this.size = size;
//         this.color = color;
//         this.font_family = font_family;
//     }

//     print(text) {
//         document.write(`
//         <p style='font-size:${this.size} ;
//         font-family:${this.font_family};
//         color:${this.color};'>${text}</p>
//         `)
//     }
// }

// obj = new PrintMachine('36pt', 'red', 'sans-serif')

// obj.print('qadfjgndfjkndsjnkjdsnvjsndvkjnskjnjdvs')



class News {
    constructor(title, text, tags, publish) {
        this.title = title;
        this.text = text;
        this.tags = tags;
        this.publish = new Date(publish);
        this.today = new Date();
    }

    print() {
        if ((this.today - this.publish) / 1000 / 60 / 60 < 24) {
        document.write(`
        <h1>${this.title}</h1>
        <p>Today</p>
        <p>${this.text}</p>
        <p>${this.tags}</p>
        `)
        } else if ((this.today - this.publish) / 1000 / 60 / 60 / 24 <= 7) {
            document.write(`
            <h1>${this.title}</h1>
            <p>${Math.round((this.today - this.publish) / 1000 / 60 / 60 / 24)} days ago</p>
            <p>${this.text}</p>
            <p>${this.tags}</p>
            `)
        } else {
            document.write(`
            <h1>${this.title}</h1>
            <p>${this.publish.toString()}</p>
            <p>${this.text}</p>
            <p>${this.tags}</p>
            `)
        }

    }
}



var a = new News('Awesome News',  'lorem100', '#tag1 #tag2', 'December 22, 2023 23:15:30')
var b = new News('Awesome News',  'lorem100', '#tag1 #tag2', 'December 22, 2023 23:15:30')
var c = new News('Awesome News',  'lorem100', '#tag1', 'December 22, 2023 23:15:30')


class ScrollNews {
    constructor() {
        this.newsArr = arguments
    }

    get news() {
       return this.newsArr.length
    }

    print() {
        for (let i = 0; i < this.newsArr.length; i++){
            this.newsArr[i].print()
        }
    }

    create_new(title, text, tags, publish) {
        this.newsArr.push(new News(title, text, tags, publish))
    }

    delete_last() {
        this.newsArr.pop()
    }

    tag_search(tag) {
        let a = new Array()
        for (let i = 0; i < this.newsArr.length; i++) {
            if (this.newsArr[i].tags.indexOf(tag) != -1) {
                a.push(this.newsArr[i].tags)
            }
        }
        return a
    }
}

var src = new ScrollNews(a,b,c)
src.print()
console.log(src.tag_search('#tag2'))