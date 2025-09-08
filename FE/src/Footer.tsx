import useLocaleDate from './useLocaleDate';

export default function Footer() {
    return <footer className="app-shell__footer">
        <div className="app-shell__footer__copyright">
            {useLocaleDate()}, WebBugsAndBeyond.
        </div>
    </footer>
}
