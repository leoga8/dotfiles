import { View, div } from "gpui-kit";
import { agents, run, props, closeOverlay } from "herdr";

// Shows agent N (cmd-alt-N), counted like the agents list grouped by space:
// pinned first, then space, tab, pane order. Opens as an invisible popup and closes at once.
const N = 1;

export default class AgentJump extends View {
  init(_props, cx) {
    const all = agents();
    const list = [...all.filter((a) => a.pinned), ...all.filter((a) => !a.pinned)];
    const a = list[N - 1];
    if (a) run("agent.focus", { terminal: a.address });
    const id = props()?.overlay;
    if (id) closeOverlay(id);
  }

  render() {
    return div();
  }
}
