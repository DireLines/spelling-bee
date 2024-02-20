using Godot;
using System;
using System.Speech.Synthesis;
using System.Runtime.InteropServices;
using System.Diagnostics;

public partial class Speaker : Node {
	public static AudioStreamWav GetKillphraseAudio(string killphrase) {
		AudioStreamWav sound = new() {
			Format = AudioStreamWav.FormatEnum.Format16Bits,
			MixRate = 22050
		};

		try {
			string wordDir = ProjectSettings.GlobalizePath("res://Audio/Speech/");
			string wordpath = wordDir + killphrase + ".wav";
			if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows)) {
				if (!System.IO.File.Exists(wordpath)) {
					SpeechSynthesizer ss = new() {
						Volume = 100
					};
					ss.SelectVoiceByHints(VoiceGender.Male, VoiceAge.Adult);

					var audioStream = new System.IO.MemoryStream();
					var formatInfo = new System.Speech.AudioFormat.SpeechAudioFormatInfo(
						22050, System.Speech.AudioFormat.AudioBitsPerSample.Sixteen, System.Speech.AudioFormat.AudioChannel.Mono
					);

					ss.SetOutputToAudioStream(audioStream, formatInfo);
					ss.Speak(killphrase);
					ss.SetOutputToNull();

					byte[] buffer = audioStream.ToArray();
					sound.Data = buffer;
					sound.SaveToWav(wordpath);
				} else {
					sound = ResourceLoader.Load<AudioStreamWav>(wordpath);
				}
			} else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX)) {
				//TODO: jank as hell
				//make it detect where ffmpeg is and give up if not exists
				//make it clean up the ogg and raw files since they crash godot
				string filepath = wordDir + killphrase;
				var sayProcess = Process.Start("/usr/bin/say","-v daniel -o " + filepath + ".ogg" + " " + killphrase);
				while (!sayProcess.HasExited) {

				}
				var ffmpegProcess =Process.Start("/opt/homebrew/bin/ffmpeg","-i " + filepath + ".ogg -f s16le -acodec pcm_s16le " + filepath + ".raw");
				while (!ffmpegProcess.HasExited) {

				}
				byte[] buffer = System.IO.File.ReadAllBytes(filepath + ".raw");
				sound.Data = buffer;
				sound.SaveToWav(wordpath);
			}
		} catch (PlatformNotSupportedException _) {
			GD.Print("Platform not supported for Speech Synthesis - get a windows computer, loser.");
		}
		return sound;
	}
}
