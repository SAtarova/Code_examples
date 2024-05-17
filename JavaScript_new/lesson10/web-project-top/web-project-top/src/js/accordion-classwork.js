const accordionList = [
    {
        id: 1,
        title: 'Long, very important, serious and interesting, frequently asked question number one?',
        type: 'question',
        order: 1
    },
    {
        id: 2,
        title: 'Long, very important, serious and interesting, frequently asked question number two?',
        type: 'question',
        order: 2
    },
    {
        id: 2,
        title: 'Long, very important, serious and interesting, frequently asked question number two?',
        type: 'question',
        order: 2
    },
    {
        id: 3,
        title: 'Long, very important, serious and interesting, frequently asked question number three?',
        type: 'question',
        order: 3
    },
    {
        id: 4,
        title: 'Long, very important, serious and interesting, frequently asked question number four?',
        type: 'question',
        order: 4
    },
    {
        id: 4,
        title: 'Long, very important, serious and interesting, frequently asked question number four?',
        type: 'question',
        order: 4
    },
    {
        id: 4,
        title: 'Long, very important, serious and interesting, frequently asked question number four?',
        type: 'question',
        order: 4
    },
    {
        id: 5,
        answer: 'Answer of first question. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad aut eaque est quo sunt. At deserunt dicta dolores incidunt iusto nam neque numquam provident quisquam totam! Aliquam architecto dignissimos distinctio, explicabo nobis odio saepe sapiente vel! Accusantium ducimus expedita illum inventore iste nam recusandae ullam vel. Consequuntur dicta illum tenetur.',
        type: 'answer',
        order: 1
    },
    {
        id: 6,
        answer: 'Answer of second question. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad aut eaque est quo sunt. At deserunt dicta dolores incidunt iusto nam neque numquam provident quisquam totam! Aliquam architecto dignissimos distinctio, explicabo nobis odio saepe sapiente vel! Accusantium ducimus expedita illum inventore iste nam recusandae ullam vel. Consequuntur dicta illum tenetur.',
        type: 'answer',
        order: 2
    },
    {
        id: 7,
        answer: 'Answer of third question. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad aut eaque est quo sunt. At deserunt dicta dolores incidunt iusto nam neque numquam provident quisquam totam! Aliquam architecto dignissimos distinctio, explicabo nobis odio saepe sapiente vel! Accusantium ducimus expedita illum inventore iste nam recusandae ullam vel. Consequuntur dicta illum tenetur.',
        type: 'answer',
        order: 3
    },
    {
        id: 8,
        answer: 'Answer of fourth question. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad aut eaque est quo sunt. At deserunt dicta dolores incidunt iusto nam neque numquam provident quisquam totam! Aliquam architecto dignissimos distinctio, explicabo nobis odio saepe sapiente vel! Accusantium ducimus expedita illum inventore iste nam recusandae ullam vel. Consequuntur dicta illum tenetur.',
        type: 'answer',
        order: 4
    }
]

const accordionMainParent = document.querySelector('.accordion-section');

if (accordionMainParent) {
    accordionList
        // Group question - answer by order
        .reduce((acc, item) => {
            if (!acc[item.order]) {
                acc[item.order] = []
            }
            acc[item.order].push(item)
            return acc;
        }, [])

        // 
        .forEach(item => {
            console.log('Necessary acc:');
            console.log(item);
            let accordionItem = `
                <li class="accordion">
                    <div class="accordion__question">
                        <p class="accordion__question-text">${item[0].title}</p>
                    </div>
                    <div class="accordion__answer">
                        <p class="accordion__answer-text">${item[1].answer}</p>
                    </div>
                </li>
            `
            accordionMainParent.insertAdjacentHTML('beforeend', accordionItem)
        })
}