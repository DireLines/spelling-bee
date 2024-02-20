using Godot;
using System;
using System.Speech.Synthesis;

public partial class Speaker : Node
{
	public static AudioStreamWav GetKillphraseAudio(string killphrase) {
        AudioStreamWav sound = new()
        {
            Format = AudioStreamWav.FormatEnum.Format16Bits,
            MixRate = 22050
        };

        try
        {
			string wordpath = ProjectSettings.GlobalizePath("res://Audio/Speech/" + killphrase + ".wav");
			if (!System.IO.File.Exists(wordpath)) {
				SpeechSynthesizer ss = new()
				{
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
		} catch (PlatformNotSupportedException _) {
			GD.Print("Platform not supported for Speech Synthesis - get a windows computer, loser.");
		}
		return sound;
	}
}
