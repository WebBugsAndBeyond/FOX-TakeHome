export default function useLocaleDate() {
    return (
        new Intl.DateTimeFormat(
            navigator.language, {
                dateStyle: 'full', timeStyle: 'long'
            }
        )
    ).format();
}
