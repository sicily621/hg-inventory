export function hexToRgb(str: string): number[] {
    let hxs: RegExpMatchArray | null = str.replace("#", "").match(/../g);
    let res: number[] = [];
    for (let i = 0; i < 3; i++) {
        if (hxs) res[i] = parseInt(hxs[i] as string, 16)
    }
    return res
}