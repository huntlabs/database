module hunt.database.mysql.impl.codec.CloseStatementCommandCodec;

import io.netty.buffer.ByteBuf;
import hunt.database.base.impl.command.CloseStatementCommand;
import hunt.database.base.impl.command.CommandResponse;

class CloseStatementCommandCodec : CommandCodec!(Void, CloseStatementCommand) {
  private static final int PAYLOAD_LENGTH = 5;

  CloseStatementCommandCodec(CloseStatementCommand cmd) {
    super(cmd);
  }

  override
  void encode(MySQLEncoder encoder) {
    super.encode(encoder);
    MySQLPreparedStatement statement = (MySQLPreparedStatement) cmd.statement();
    sendCloseStatementCommand(statement);

    completionHandler.handle(CommandResponse.success(null));
  }

  override
  void decodePayload(ByteBuf payload, int payloadLength, int sequenceId) {
    // no statement response
  }

  private void sendCloseStatementCommand(MySQLPreparedStatement statement) {
    ByteBuf packet = allocateBuffer(PAYLOAD_LENGTH + 4);
    // encode packet header
    packet.writeMediumLE(PAYLOAD_LENGTH);
    packet.writeByte(sequenceId);

    // encode packet payload
    packet.writeByte(CommandType.COM_STMT_CLOSE);
    packet.writeIntLE((int) statement.statementId);

    sendNonSplitPacket(packet);
  }
}
