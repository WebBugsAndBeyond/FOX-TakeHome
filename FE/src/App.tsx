import Posts, { type Post } from './Posts';
import PostAccordion from './PostAccordion';
import './App.css'
import Header from './Header';
import Footer from './Footer';

function App() {

  return (
    <>
        <Header />
        <main>
            <div className="main-content__feed-accordion-wrapper">
                <Posts renderPost={(post: Post) => <PostAccordion key={post.id} post={post} />} />
            </div>
        </main>
        <Footer />
    </>
  );
}

export default App
