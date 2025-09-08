import { useCallback, useState } from 'react';
import { type Post } from './Posts';

export type PostAccordionProps = {
    post: Post;
}

export default function PostAccordion({ post }: PostAccordionProps ) {

    const [expanded, setExpanded] = useState<boolean>(false);
    const handleExpandCollapse = useCallback(() => {
        setExpanded(prevValue => !prevValue);
    }, []);
    const expandStateClassName: string = expanded ? 'expanded' : '';
    return <article>
        <h1 part="header"><button className="title"
            onClick={handleExpandCollapse}
        >{post.title}</button></h1>
        <div part="content" className={expandStateClassName}>
            <div>
                <div className="description">{post.body}</div>
            </div>
        </div>
    </article>
}
