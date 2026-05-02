from __future__ import annotations

import argparse
from array import array
import subprocess
import wave
from pathlib import Path


DEFAULT_FLUIDSYNTH = Path(
    r"C:\Users\Home\Downloads\orbwalker\fluidsynth-v2.5.4-win10-x64-cpp11"
    r"\fluidsynth-v2.5.4-win10-x64-cpp11\bin\fluidsynth.exe"
)
DEFAULT_SOUNDFONT = Path("raw/GeneralUser GS v1.471.sf2")
DEFAULT_OUTPUT_DIR = Path("resources/audio/music")
DEFAULT_SAMPLE_RATE = 44100
DEFAULT_GAIN = 0.8
DEFAULT_PEAK = 0.85


def render_midi(
    fluidsynth_path: Path,
    midi_path: Path,
    soundfont_path: Path,
    output_path: Path,
    sample_rate: int,
    gain: float,
    peak: float,
) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    command = [
        str(fluidsynth_path),
        "-ni",
        "-q",
        "-T",
        "wav",
        "-O",
        "s16",
        "-r",
        str(sample_rate),
        "-g",
        str(gain),
        "-F",
        str(output_path),
        str(soundfont_path),
        str(midi_path),
    ]
    result = subprocess.run(command, check=False, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(
            "FluidSynth failed for %s\nstdout:\n%s\nstderr:\n%s"
            % (midi_path, result.stdout, result.stderr)
        )
    _normalize_wav(output_path, peak)
    _verify_wav(output_path)


def _verify_wav(output_path: Path) -> None:
    with wave.open(str(output_path), "rb") as wav:
        if wav.getnchannels() != 2:
            raise RuntimeError(f"{output_path} is not stereo WAV audio")
        if wav.getsampwidth() != 2:
            raise RuntimeError(f"{output_path} is not signed 16-bit WAV audio")
        if wav.getnframes() <= 0:
            raise RuntimeError(f"{output_path} has no audio frames")


def _normalize_wav(output_path: Path, target_peak: float) -> None:
    if target_peak <= 0.0:
        return
    with wave.open(str(output_path), "rb") as wav:
        params = wav.getparams()
        frames = wav.readframes(wav.getnframes())
    if params.sampwidth != 2 or not frames:
        return

    samples = array("h")
    samples.frombytes(frames)
    if samples.itemsize != 2:
        return
    current_peak = max(abs(sample) for sample in samples)
    if current_peak <= 0:
        return
    gain = min(32767.0, target_peak * 32767.0) / float(current_peak)
    for index, sample in enumerate(samples):
        samples[index] = max(-32768, min(32767, int(round(float(sample) * gain))))

    with wave.open(str(output_path), "wb") as wav:
        wav.setparams(params)
        wav.writeframes(samples.tobytes())


def main() -> None:
    parser = argparse.ArgumentParser(description="Render MIDI files to WAV with FluidSynth.")
    parser.add_argument("midi", nargs="*", type=Path, help="MIDI file(s) to render.")
    parser.add_argument("--fluidsynth", type=Path, default=DEFAULT_FLUIDSYNTH)
    parser.add_argument("--soundfont", type=Path, default=DEFAULT_SOUNDFONT)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--sample-rate", type=int, default=DEFAULT_SAMPLE_RATE)
    parser.add_argument("--gain", type=float, default=DEFAULT_GAIN)
    parser.add_argument("--peak", type=float, default=DEFAULT_PEAK)
    args = parser.parse_args()

    if not args.fluidsynth.exists():
        raise SystemExit(f"FluidSynth not found: {args.fluidsynth}")
    if not args.soundfont.exists():
        raise SystemExit(f"SoundFont not found: {args.soundfont}")

    midi_files = args.midi or sorted(Path("raw").glob("*.mid")) + sorted(Path("raw").glob("*.midi"))
    if not midi_files:
        raise SystemExit("No MIDI files found.")

    for midi_path in midi_files:
        output_path = args.output_dir / f"{midi_path.stem}.wav"
        render_midi(
            fluidsynth_path=args.fluidsynth,
            midi_path=midi_path,
            soundfont_path=args.soundfont,
            output_path=output_path,
            sample_rate=args.sample_rate,
            gain=args.gain,
            peak=args.peak,
        )
        print(f"{midi_path} -> {output_path}")


if __name__ == "__main__":
    main()
