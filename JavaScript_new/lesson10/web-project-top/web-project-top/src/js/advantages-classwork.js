const advantagesList = [
    {
        id: 1,
        title: 'Title of the first advantage',
        body: 'A small text describing one of the goals in two lines. A small text describing one of the goals in two lines. A small text describing one of the goals in two lines.',
        img: {
            src: './images/home-page/advantages/advantage-001.jpeg',
            alt: 'Our first advantage demonstration'
        },
        old: false
    },
    {
        id: 2,
        title: 'Title of the second advantage Title of the second advantage',
        body: 'A small text describing one of the goals in two lines.',
        img: {
            src: './images/home-page/advantages/advantage-002.jpeg',
            alt: 'Our second advantage demonstration'
        },
        old: false
    },
    {
        id: 3,
        title: 'Title of the third advantage',
        body: 'A small text describing one of the goals in two lines.',
        img: {
            src: './images/home-page/advantages/advantage-003.jpeg',
            alt: 'Our third advantage demonstration'
        },
        old: false
    },
    {
        id: 4,
        title: 'Title of the fourth advantage Title of the fourth advantage Title of the fourth advantage',
        body: 'A small text describing one of the goals in two lines. A small text describing one of the goals in two lines.',
        img: {
            src: './images/home-page/advantages/advantage-001.jpeg',
            alt: 'Our fourth advantage demonstration'
        },
        old: false
    },
    {
        id: 5,
        title: 'Title of the fifth  advantage Title of the fifth  advantage',
        body: 'A small text describing one of the goals in two lines. A small text describing one of the goals in two lines. A small text describing one of the goals in two lines. A small text describing one of the goals in two lines.',
        img: {
            src: './images/home-page/advantages/advantage-002.jpeg',
            alt: 'Our fifth advantage demonstration'
        },
        old: false
    },
    {
        id: 6,
        title: 'Title of the sixth advantage',
        body: 'A small text describing one of the goals in two lines.',
        img: {
            src: './images/home-page/advantages/advantage-003.jpeg',
            alt: 'Our sixth advantage demonstration'
        },
        old: false
    }
]

const advantageMainParent = document.querySelector('.hp-advantages__list');

if (advantageMainParent)
{
    advantagesList
        .filter(item => item.old === false)
        .forEach(item =>
        {
            let currentAdvantage = `
                    <li class="hp-advantages__list-item">
                        <img class="hp-advantages__list-item-image" src="./images/home-page/advantages/advantage-003.jpeg" alt="">
                        <div class="hp-advantages__list-item-wrapper">
                            <span class="hp-advantages__list-item-order"> ${item.id < 10 ? "0" + item.id : null}</span>
                            <div class="hp-advantages__list-item-text">
                                <p class="hp-advantages__list-item-title"> ${item.title.length > 30 ? item.title.slice(0, 30) + "..." : item.title}</p>
                                <p class="hp-advantages__list-item-description"> ${item.body.length > 55 ? item.body.slice(0, 55) + "..." : item.body}</p>
                            </div>
                        </div>
                    </li>`;
            advantageMainParent.insertAdjacentHTML('beforeend', currentAdvantage)
        })
}