import { useEffect, useState, type ReactNode } from "react";

export type Post = {
    userId: number;
    id: number;
    title: string;
    body: string;
}

export type PostsProps = {
    renderPost: (post: Post) => ReactNode;
}

export default function Posts({ renderPost }: PostsProps) {
    const [posts, setPosts] = useState<Post[] | null>(null);

    useEffect(() => {
        if (posts === null) {
            const abortController: AbortController = new AbortController();
            fetch('https://jsonplaceholder.typicode.com/posts', {
                signal: abortController.signal,
            })
                .then((response: Response) => response.json())
                .then((postsResponse: Post[]) => setPosts(postsResponse))
                .catch((error) => console.log(error));
            return () => abortController.abort('Probably dev-mode stress testing.');
        }
    }, [posts]);
    return posts && posts.map(renderPost);
}
