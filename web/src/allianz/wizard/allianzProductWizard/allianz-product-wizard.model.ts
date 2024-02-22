export interface IChannel {
    id: number;
    name: string;
    article: Array<IArticle>;
    template?: string;
}

export interface IText {
    id: number,
    label: string
}

export interface IArticle {
    id: number | string;
    name: string;
    text?: IText
    optionalComponent?: boolean | string;
    optionalComponents?: Array<OptionalComponent>;
    isInstance?: boolean;
    type: string;
}

export interface OptionalComponent {
    name: string,
    id: number,
    template: string
}

export interface IProduct {
    name: string;
    type: string;
    domain?: string;
}

export function sortArticle(a,b) {
    const itemOrder: Array<String> = [
        'article.header.',
        'article.produktbeschreibung.',
        'article.funktionsgrafik.',
        'article.vorteile.',
        'article.fallbeispiel.',
        'article.nutzenversprechen.',
        'article.zielgruppenmodul.',
        'article.productdetails.',
        'article.staerken.',
        'article.faq.',
        'article.baveinsatz.',
        'article.schichten.'
    ]
    return itemOrder.indexOf(a.type) - itemOrder.indexOf(b.type);
}