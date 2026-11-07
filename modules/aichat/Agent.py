#!/usr/bin/env python3
import json
import os
import signal
import subprocess
import sys
import threading
import shutil

MODEL = "gemini-3.8-flash-low"

agent = None
write_lock = threading.Lock()


def emit(event):
    """Envía un evento JSON por línea a Quickshell."""
    try:
        print(json.dumps(event, ensure_ascii=False), flush=True)
    except Exception:
        pass


def stop_agent(*_args):
    """Evita dejar agy ejecutándose si se cierra el backend."""
    global agent

    if agent is not None and agent.poll() is None:
        try:
            agent.terminate()
            agent.wait(timeout=3)
        except subprocess.TimeoutExpired:
            agent.kill()
            agent.wait()
        except Exception:
            pass

    sys.exit(0)


def forward_output():
    """Reenvía los eventos de agy conforme llegan."""
    try:
        for line in agent.stdout:
            if line.strip():
                print(line.rstrip("\n"), flush=True)
    except Exception as exc:
        emit({"event": "bridge_error", "message": f"Error leyendo agy: {exc}"})


def main():
    global agent

    signal.signal(signal.SIGTERM, stop_agent)
    signal.signal(signal.SIGINT, stop_agent)

    agy_bin = shutil.which("agy") or os.path.expanduser("~/.local/bin/agy")
    if not os.path.exists(agy_bin):
        emit({"event": "bridge_error", "message": f"No se encontró el ejecutable agy en {agy_bin}"})
        return 1

    try:
        agent = subprocess.Popen(
            [
                agy_bin,
                "--model", MODEL,
                "--input-format", "stream-json",
                "--output-format", "stream-json",
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            encoding="utf-8",
            bufsize=1,
        )
    except Exception as exc:
        emit({"event": "bridge_error", "message": f"Fallo al iniciar agy: {exc}"})
        return 1

    reader = threading.Thread(target=forward_output, daemon=True)
    reader.start()

    try:
        for line in sys.stdin:
            if not line.strip():
                continue

            # Validamos el JSON antes de enviarlo al agente
            try:
                message = json.loads(line)
            except json.JSONDecodeError:
                emit({
                    "event": "bridge_error",
                    "message": "El mensaje recibido no es JSON válido.",
                })
                continue

            if message.get("event") != "user":
                continue

            if agent.poll() is not None:
                emit({
                    "event": "bridge_error",
                    "message": "El proceso agy ya terminó.",
                })
                break

            try:
                with write_lock:
                    agent.stdin.write(
                        json.dumps(message, ensure_ascii=False) + "\n"
                    )
                    agent.stdin.flush()
            except (BrokenPipeError, OSError) as exc:
                emit({
                    "event": "bridge_error",
                    "message": f"No se pudo enviar el mensaje a agy: {exc}",
                })
                break
    finally:
        stop_agent()

    return 0


if __name__ == "__main__":
    sys.exit(main())
